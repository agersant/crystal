pub use self::builder::NavigationMeshBuilder;
use crate::extensions::*;
use geo::prelude::*;
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

	fn project_point_to_nearest_navigable_face<'a>(
		&self,
		point: &Point<f32>,
		candidates: &Vec<FaceHandle<'a, Vertex, CdtEdge>>,
	) -> ProjectionResult<'a> {
		candidates
			.iter()
			.filter(|f| self.is_face_navigable(&f))
			.map(|f| ProjectionResult {
				nearest_point: f.project_point(point),
				nearest_face: *f,
			})
			.min_by(|a, b| {
				OrderedFloat(a.nearest_point.euclidean_distance(point))
					.cmp(&OrderedFloat(b.nearest_point.euclidean_distance(point)))
			})
			.unwrap()
	}

	fn project_point_to_playable_space(&self, point: &Point<f32>) -> Option<ProjectionResult> {
		let locate = self.triangulation.locate(&[point.x(), point.y()]);
		let projection = match locate {
			PositionInTriangulation::NoTriangulationPresent => return None,
			PositionInTriangulation::InTriangle(f) => {
				if self.is_face_navigable(&f) {
					self.project_point_to_nearest_navigable_face(point, &vec![f])
				} else {
					self.project_point_to_nearest_navigable_face(point, &f.adjacent_faces())
				}
			}
			PositionInTriangulation::OnPoint(v) => {
				self.project_point_to_nearest_navigable_face(point, &v.adjacent_faces())
			}
			PositionInTriangulation::OutsideConvexHull(e) | PositionInTriangulation::OnEdge(e) => {
				self.project_point_to_nearest_navigable_face(point, &e.adjacent_faces())
			}
		};
		Some(projection)
	}

	pub fn get_nearest_navigable_point(&self, point: &Point<f32>) -> Option<Point<f32>> {
		self.project_point_to_playable_space(point)
			.map(|p| p.nearest_point)
	}

	pub fn compute_path(&self, from: &Point<f32>, to: &Point<f32>) -> Option<LineString<f32>> {
		// Project start and end to playable space
		let from_projection = self.project_point_to_playable_space(from);
		let to_projection = self.project_point_to_playable_space(to);

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

				return Some(path.into());
			}
		}

		None
	}

	#[cfg(test)]
	pub fn bounding_box(&self) -> (Point<f32>, Point<f32>) {
		use geo::prelude::*;
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

fn heuristic(from: &FaceHandle<Vertex, CdtEdge>, to: &Point<f32>) -> f32 {
	let line = Line::new(from.center(), to.clone());
	line.length()
}

fn movement_cost(from: &FaceHandle<Vertex, CdtEdge>, to: &FaceHandle<Vertex, CdtEdge>) -> f32 {
	let line = Line::new(from.center(), to.center());
	line.length()
}
