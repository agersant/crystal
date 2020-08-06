use crate::geometry::{Polygon, Vertex};
use crate::mesh::collision::CollisionMesh;
use itertools::Itertools;
use spade::delaunay::ConstrainedDelaunayTriangulation;
use spade::delaunay::DelaunayTreeLocate;
use spade::delaunay::FloatCDT;
use spade::kernels::FloatKernel;

type Triangulation =
	ConstrainedDelaunayTriangulation<[f32; 2], FloatKernel, DelaunayTreeLocate<[f32; 2]>>;

pub struct NavigationMesh {
	triangulation: Triangulation,
}

impl NavigationMesh {
	pub fn build(width: f32, height: f32, collision_mesh: &CollisionMesh) -> NavigationMesh {
		// TODO pad obstacles

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

		// TODO remove triangles within obstacles

		NavigationMesh { triangulation }
	}

	pub fn get_triangles(&self) -> Vec<Polygon> {
		let mut polygons = Vec::new();
		for face in self.triangulation.triangles() {
			let triangle = face.as_triangle();
			let mut vertices = Vec::new();
			for i in 0..3 {
				vertices.push(Vertex {
					x: triangle[i][0],
					y: triangle[i][1],
				});
			}
			polygons.push(Polygon { vertices });
		}
		polygons
	}
}

impl Default for NavigationMesh {
	fn default() -> Self {
		NavigationMesh {
			triangulation: FloatCDT::with_tree_locate(),
		}
	}
}
