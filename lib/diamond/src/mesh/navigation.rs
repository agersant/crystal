use crate::geometry::{Polygon, Vertex};
use crate::mesh::collision::CollisionMesh;
use geo::algorithm::intersects::Intersects;
use geo_booleanop::boolean::BooleanOp;
use geo_types::polygon;
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
}

impl NavigationMesh {
	pub fn build(width: f32, height: f32, collision_mesh: &CollisionMesh) -> NavigationMesh {
		let padding = 4.0; // TODO builder input
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
		for polygon in playable_space {
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
		}
	}

	pub fn get_triangles(&self) -> Vec<Polygon> {
		let mut polygons = Vec::new();
		for face in self.triangulation.triangles() {
			if !self.navigable_triangles.contains(&face.fix()) {
				continue;
			}
			polygons.push(face_to_polygon(&face));
		}
		polygons
	}
}

impl Default for NavigationMesh {
	fn default() -> Self {
		NavigationMesh {
			triangulation: FloatCDT::with_tree_locate(),
			navigable_triangles: HashSet::new(),
		}
	}
}

fn pad_obstacle(obstacle: &geo_types::Polygon<f32>, offset: f32) -> geo_types::Polygon<f32> {
	let exterior: Polygon = obstacle.exterior().into();
	let padded_exterior = exterior.offset(offset);
	let padded_interiors: Vec<Polygon> = obstacle
		.interiors()
		.iter()
		.map(|interior| {
			let interior: Polygon = interior.into();
			interior.offset(-offset)
		})
		.collect();
	geo_types::Polygon::new(
		(&padded_exterior).into(),
		padded_interiors.iter().map(|i| i.into()).collect(),
	)
}

fn face_to_polygon(face: &FaceHandle<[f32; 2], spade::delaunay::CdtEdge>) -> Polygon {
	let triangle = face.as_triangle();
	let mut vertices = Vec::new();
	for i in 0..3 {
		vertices.push(Vertex {
			x: triangle[i][0],
			y: triangle[i][1],
		});
	}
	Polygon { vertices }
}

fn face_to_geo_polygon(
	face: &FaceHandle<[f32; 2], spade::delaunay::CdtEdge>,
) -> geo_types::Polygon<f32> {
	let triangle = face.as_triangle();
	polygon![(x: triangle[0][0], y: triangle[0][1]), (x: triangle[1][0], y: triangle[1][1]),(x: triangle[2][0], y: triangle[2][1])]
}
