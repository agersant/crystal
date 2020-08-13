use crate::geometry::LineStringExt;
use crate::mesh::collision::CollisionMesh;
use geo::algorithm::closest_point::ClosestPoint;
use geo::algorithm::intersects::Intersects;
use geo::Closest;
use geo_booleanop::boolean::BooleanOp;
use geo_types::*;
use spade::delaunay::{
	ConstrainedDelaunayTriangulation, DelaunayTreeLocate, FaceHandle, FixedFaceHandle, FloatCDT,
};
use spade::kernels::FloatKernel;
use std::collections::HashSet;

type Triangulation =
	ConstrainedDelaunayTriangulation<[f32; 2], FloatKernel, DelaunayTreeLocate<[f32; 2]>>;

pub struct NavigationMesh {
	triangulation: Triangulation,
	navigable_triangles: HashSet<FixedFaceHandle>,
	playable_space: MultiPolygon<f32>,
}

impl NavigationMesh {
	pub fn build(
		width: f32,
		height: f32,
		collision_mesh: &CollisionMesh,
		padding: f32,
	) -> NavigationMesh {
		type MP = geo_types::MultiPolygon<f32>;

		// Determine playable space
		let mut playable_space: MP = polygon![
			(x: padding, y: padding),
			(x: width - padding, y: padding),
			(x: width - padding, y: height - padding),
			(x: padding, y: height - padding)
		]
		.into();

		// TODO avoid cloning here
		for obstacle in collision_mesh.obstacles.clone() {
			let padded_obstacle = pad_obstacle(&obstacle, padding);
			playable_space = playable_space.difference(&padded_obstacle);
		}

		// Triangulate
		let mut triangulation = FloatCDT::with_tree_locate();
		// TODO avoid cloning here
		for polygon in playable_space.clone() {
			for line in polygon.exterior().lines() {
				let handle0 = triangulation.insert([line.start.x, line.start.y]);
				let handle1 = triangulation.insert([line.end.x, line.end.y]);
				if triangulation.can_add_constraint(handle0, handle1) {
					triangulation.add_constraint(handle0, handle1);
				}
			}
			for interior in polygon.interiors() {
				for line in interior.lines() {
					let handle0 = triangulation.insert([line.start.x, line.start.y]);
					let handle1 = triangulation.insert([line.end.x, line.end.y]);
					if triangulation.can_add_constraint(handle0, handle1) {
						triangulation.add_constraint(handle0, handle1);
					}
				}
			}
		}

		// Flag walkable triangles
		let mut navigable_triangles = HashSet::new();
		for face in triangulation.triangles() {
			let triangle = face_to_geo_polygon(&face);
			let is_walkable = !collision_mesh
				.obstacles
				.clone()
				.into_iter()
				.any(|p| p.intersects(&triangle));
			if is_walkable {
				navigable_triangles.insert(face.fix());
			}
		}

		NavigationMesh {
			triangulation,
			navigable_triangles,
			playable_space: playable_space,
		}
	}

	pub fn get_triangles(&self) -> Vec<Triangle<f32>> {
		let mut triangles = Vec::new();
		for face in self.triangulation.triangles() {
			if !self.navigable_triangles.contains(&face.fix()) {
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

	pub fn get_nearest_navigable_point(&self, from: &Point<f32>) -> Point<f32> {
		match self.playable_space.closest_point(from) {
			Closest::SinglePoint(p) => p,
			Closest::Intersection(p) => p,
			Closest::Indeterminate => from.clone(),
		}
	}
}

impl Default for NavigationMesh {
	fn default() -> Self {
		NavigationMesh {
			triangulation: FloatCDT::with_tree_locate(),
			navigable_triangles: HashSet::new(),
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
