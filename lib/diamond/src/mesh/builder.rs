use crate::geometry::*;
use crate::mesh::collision::CollisionMesh;
use crate::mesh::navigation::NavigationMesh;
use crate::mesh::Mesh;
use ndarray::Array2;

#[derive(Debug)]
pub struct MeshBuilder {
	polygons: Array2<Vec<geo_types::Polygon<f32>>>,
	num_tiles_x: usize,
	num_tiles_y: usize,
}

impl MeshBuilder {
	pub fn new(num_tiles_x: i32, num_tiles_y: i32) -> MeshBuilder {
		let w = num_tiles_x as usize;
		let h = num_tiles_y as usize;
		MeshBuilder {
			polygons: Array2::from_elem((h, w), Vec::<geo_types::Polygon<f32>>::new()),
			num_tiles_x: w,
			num_tiles_y: h,
		}
	}

	pub fn add_polygon(&mut self, tile_x: i32, tile_y: i32, polygon: Polygon) {
		if polygon.vertices.len() == 0 {
			return;
		}
		let x = tile_x as usize;
		let y = tile_y as usize;
		if x >= self.num_tiles_x || y >= self.num_tiles_y {
			return;
		}
		self.polygons[(y, x)].push((&polygon).into());
	}

	pub fn build(&self) -> Mesh {
		let collision_mesh =
			CollisionMesh::build(self.num_tiles_x, self.num_tiles_y, &self.polygons);
		let navigation_mesh = NavigationMesh::build(&collision_mesh);
		Mesh {
			collision: collision_mesh,
			navigation: navigation_mesh,
		}
	}
}
