use crate::mesh::collision::CollisionMesh;
use crate::mesh::navigation::NavigationMesh;
use crate::mesh::Mesh;
use geo_types::*;
use ndarray::Array2;

#[derive(Debug)]
pub struct MeshBuilder {
	obstacles: Array2<Vec<LineString<f32>>>,
	num_tiles_x: usize,
	num_tiles_y: usize,
	tile_width: f32,
	tile_height: f32,
}

impl MeshBuilder {
	pub fn new(
		num_tiles_x: i32,
		num_tiles_y: i32,
		tile_width: f32,
		tile_height: f32,
	) -> MeshBuilder {
		let w = num_tiles_x as usize;
		let h = num_tiles_y as usize;
		MeshBuilder {
			obstacles: Array2::from_elem((h, w), Vec::<LineString<f32>>::new()),
			num_tiles_x: w,
			num_tiles_y: h,
			tile_width,
			tile_height,
		}
	}

	pub fn add_polygon(&mut self, tile_x: i32, tile_y: i32, line_string: LineString<f32>) {
		if line_string.num_coords() == 0 {
			return;
		}
		let x = tile_x as usize;
		let y = tile_y as usize;
		if x >= self.num_tiles_x || y >= self.num_tiles_y {
			return;
		}
		self.obstacles[(y, x)].push(line_string);
	}

	pub fn build(&self) -> Mesh {
		let collision_mesh =
			CollisionMesh::build(self.num_tiles_x, self.num_tiles_y, &self.obstacles);

		let w = self.num_tiles_x as f32 * self.tile_width;
		let h = self.num_tiles_y as f32 * self.tile_height;
		let navigation_mesh = NavigationMesh::build(w, h, &collision_mesh);
		Mesh {
			collision: collision_mesh,
			navigation: navigation_mesh,
		}
	}
}
