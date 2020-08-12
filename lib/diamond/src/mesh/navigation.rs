use crate::geometry::{Polygon, Vertex};
use crate::mesh::collision::CollisionMesh;
use geo::algorithm::centroid::Centroid;
use geo::algorithm::contains::Contains;
use geo_types::{polygon, Geometry, GeometryCollection};
use itertools::Itertools;
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
		// TODO pad obstacles

		let all_obstacles = GeometryCollection(
			collision_mesh
				.obstacles
				.clone() // TODO avoid cloning
				.into_iter()
				.map(|p| Geometry::Polygon(p))
				.collect(),
		);

		let mut triangulation = FloatCDT::with_tree_locate();
		triangulation.insert([0.0, 0.0]);
		triangulation.insert([width, 0.0]);
		triangulation.insert([width, height]);
		triangulation.insert([0.0, height]);

		let contours = collision_mesh.get_contours();
		for polygon in &contours {
			for (v0, v1) in polygon.vertices.iter().tuple_windows() {
				let handle0 = triangulation.insert([v0.x, v0.y]);
				let handle1 = triangulation.insert([v1.x, v1.y]);
				if triangulation.can_add_constraint(handle0, handle1) {
					triangulation.add_constraint(handle0, handle1);
				}
			}
		}

		let mut navigable_triangles = HashSet::new();
		for face in triangulation.triangles() {
			let triangle = face_to_geo_polygon(&face);
			let triangle_center = triangle.centroid().unwrap();
			if !all_obstacles.contains(&triangle_center) {
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
