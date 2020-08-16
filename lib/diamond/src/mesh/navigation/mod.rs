pub use self::builder::NavigationMeshBuilder;
use crate::geometry::*;
use geo::prelude::*;
use geo::Closest;
use geo_booleanop::boolean::BooleanOp;
use geo_types::*;
use ordered_float::OrderedFloat;
use pathfinding::prelude::*;
use spade::delaunay::*;
use spade::kernels::FloatKernel;
use std::collections::HashSet;

mod builder;
mod smoothing;
#[cfg(test)]
mod tests;

pub type Vertex = [f32; 2];

const EPSILON: f32 = 1.0 / 100.0;

type Triangulation =
	ConstrainedDelaunayTriangulation<Vertex, FloatKernel, DelaunayTreeLocate<[f32; 2]>>;

pub struct NavigationMesh {
	triangulation: Triangulation,
	navigable_faces: HashSet<FixedFaceHandle>,
	playable_space: MultiPolygon<f32>,
}

#[derive(Debug)]
struct ProjectionResult<'a> {
	nearest_point: Point<f32>,
	nearest_face: FaceHandle<'a, Vertex, CdtEdge>,
}

impl NavigationMesh {
	pub fn builder(width: f32, height: f32) -> NavigationMeshBuilder {
		NavigationMeshBuilder::new(width, height)
	}

	pub fn is_face_navigable(&self, face: &FaceHandle<Vertex, CdtEdge>) -> bool {
		self.navigable_faces.contains(&face.fix())
	}

	pub fn get_triangles(&self) -> Vec<Triangle<f32>> {
		let mut triangles = Vec::new();
		for face in self.triangulation.triangles() {
			if !self.navigable_faces.contains(&face.fix()) {
				continue;
			}
			let face = face.as_triangle();
			let triangle = Triangle(
				Coordinate {
					x: face[0][0],
					y: face[0][1],
				},
				Coordinate {
					x: face[1][0],
					y: face[1][1],
				},
				Coordinate {
					x: face[2][0],
					y: face[2][1],
				},
			);
			triangles.push(triangle);
		}
		triangles
	}

	fn project_to_playable_space(&self, point: &Point<f32>) -> Option<ProjectionResult> {
		// TODO Ideally we would not call get_nearest_navigable_point at all here. See https://github.com/Stoeoef/spade/issues/58
		let nearest_point = self.get_nearest_navigable_point(point);

		if let Some(nearest_point) = nearest_point {
			let locate = self
				.triangulation
				.locate(&[nearest_point.x(), nearest_point.y()]);

			let nearest_face = match locate {
				PositionInTriangulation::NoTriangulationPresent => return None,
				PositionInTriangulation::InTriangle(f) => f,

				PositionInTriangulation::OnPoint(v) => {
					match v.ccw_out_edges().into_iter().find_map(|edge| {
						if self.is_face_navigable(&edge.face()) {
							Some(edge.face())
						} else {
							None
						}
					}) {
						Some(f) => f,
						None => return None,
					}
				}

				PositionInTriangulation::OutsideConvexHull(e)
				| PositionInTriangulation::OnEdge(e) => {
					let left = e.face();
					let right = e.sym().face();
					if self.is_face_navigable(&left) {
						left
					} else {
						right
					}
				}
			};

			return Some(ProjectionResult {
				nearest_face,
				nearest_point,
			});
		}
		None
	}

	// TODO Ideally we would use triangulation.locate() for this, but this would required a resolution to https://github.com/Stoeoef/spade/issues/58
	pub fn get_nearest_navigable_point(&self, point: &Point<f32>) -> Option<Point<f32>> {
		if self.playable_space.contains(point) {
			return Some(point.clone());
		}
		match self.playable_space.closest_point(point) {
			Closest::SinglePoint(p) => Some(p),
			Closest::Intersection(p) => Some(p),
			Closest::Indeterminate => None,
		}
		.and_then(|p| {
			let deltas = [(0.0, 0.0), (1.0, 0.0), (-1.0, 0.0), (0.0, 1.0), (0.0, -1.0)];
			for (dx, dy) in deltas.iter() {
				let p = Point::new(p.x() + dx * EPSILON, p.y() + dy * EPSILON);
				if self.playable_space.contains(&p) {
					return Some(p);
				}
			}
			None
		})
	}

	pub fn compute_path(&self, from: &Point<f32>, to: &Point<f32>) -> LineString<f32> {
		// Project start and end to playable space
		let from_projection = self.project_to_playable_space(from);
		let to_projection = self.project_to_playable_space(to);

		if let (Some(mesh_start), Some(mesh_end)) = (&from_projection, &to_projection) {
			// Compute path
			let path = astar(
				&mesh_start.nearest_face.fix(),
				|&face| {
					let face = self.triangulation.face(face);
					face.adjacent_edges()
						.filter(|e| self.is_face_navigable(&e.sym().face()))
						.map(move |e| {
							let neighbour = e.sym().face();
							let cost = movement_cost(&face, &neighbour);
							(neighbour.fix(), OrderedFloat(cost))
						})
				},
				|&face| {
					let face = self.triangulation.face(face);
					OrderedFloat(heuristic(&face, to))
				},
				|&face| face == mesh_end.nearest_face.fix(),
			);

			// Funnel
			let path = path.map(|(triangle_path, _length)| {
				smoothing::funnel(
					self,
					&mesh_start.nearest_point,
					&mesh_end.nearest_point,
					triangle_path,
				)
			});

			// Make sure start and end are in the path, in case they were outside of playable area
			if let Some(mut path) = path {
				if *from != mesh_start.nearest_point {
					path.insert(0, *from);
				}
				if *to != mesh_end.nearest_point {
					path.push(*to);
				}

				return path.into();
			} else {
				// TODO
			}
		} else {
			// TODO
		}

		vec![*from, *to].into()
	}

	#[cfg(test)]
	pub fn bounding_box(&self) -> (Point<f32>, Point<f32>) {
		if self.playable_space.unsigned_area() == 0.0 {
			return (Point::new(0.0, 0.0), Point::new(0.0, 0.0));
		}
		let extremes = self.playable_space.extreme_points();
		(
			Point::new(extremes.xmin.x(), extremes.ymin.y()),
			Point::new(extremes.xmax.x(), extremes.ymax.y()),
		)
	}
}

impl Default for NavigationMesh {
	fn default() -> Self {
		NavigationMesh {
			triangulation: FloatCDT::with_tree_locate(),
			navigable_faces: HashSet::new(),
			playable_space: Vec::<Polygon<f32>>::new().into(),
		}
	}
}

// This assumes that offset is small enough to not change the topology of the polygon (does not create self-intersection, merge interiors, etc.)
fn pad_obstacle(obstacle: &geo_types::Polygon<f32>, offset: f32) -> geo_types::Polygon<f32> {
	let padded_exterior = obstacle.exterior().offset(offset);
	let padded_interiors: Vec<LineString<f32>> = obstacle
		.interiors()
		.iter()
		.map(|interior| interior.offset(-offset))
		.collect();
	geo_types::Polygon::new(padded_exterior, padded_interiors)
}

// TODO revisit this?
fn face_to_geo_polygon(
	face: &FaceHandle<[f32; 2], spade::delaunay::CdtEdge>,
) -> geo_types::Polygon<f32> {
	let triangle = face.as_triangle();
	polygon![(x: triangle[0][0], y: triangle[0][1]), (x: triangle[1][0], y: triangle[1][1]),(x: triangle[2][0], y: triangle[2][1])]
}

fn heuristic(from: &FaceHandle<Vertex, CdtEdge>, to: &Point<f32>) -> f32 {
	let line = Line::new(from.center(), to.clone());
	line.length()
}

fn movement_cost(from: &FaceHandle<Vertex, CdtEdge>, to: &FaceHandle<Vertex, CdtEdge>) -> f32 {
	let line = Line::new(from.center(), to.center());
	line.length()
}
