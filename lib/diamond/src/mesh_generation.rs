use crate::types::*;
use geo::algorithm::simplifyvw::SimplifyVW;
use geo_booleanop::boolean::BooleanOp;
use ndarray::parallel::prelude::*;
use ndarray::Array;
use ndarray::Array2;
use ndarray::Axis;
use rayon::iter::IndexedParallelIterator;
use rayon::iter::IntoParallelIterator;

#[derive(Debug)]
pub struct CollisionMeshBuilder {
	polygons: Array2<Vec<geo_types::Polygon<f32>>>,
	num_tiles_x: usize,
	num_tiles_y: usize,
}

impl CollisionMeshBuilder {
	pub fn new(num_tiles_x: i32, num_tiles_y: i32) -> CollisionMeshBuilder {
		let w = num_tiles_x as usize;
		let h = num_tiles_y as usize;
		CollisionMeshBuilder {
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

	pub fn build(&self) -> CollisionMesh {
		type P = geo_types::Polygon<f32>;
		type MP = geo_types::MultiPolygon<f32>;

		let mut w = self.num_tiles_x;
		let mut h = self.num_tiles_y;

		// Initial state
		let mut reduced_map: Array2<MP> =
			Array::from_shape_fn((h, w), |(y, x)| self.polygons[(y, x)].clone().into());

		// Iterative collapse of 2x2 blocks
		while w > 1 && h > 1 {
			w = (w as f32 / 2.0).ceil() as usize;
			h = (h as f32 / 2.0).ceil() as usize;

			let p: Vec<Vec<MP>> = reduced_map
				.axis_chunks_iter(Axis(0), 2)
				.into_par_iter()
				.enumerate()
				.map(|(y, y_view)| {
					let polys: Vec<MP> = y_view
						.axis_chunks_iter(Axis(1), 2)
						.into_par_iter()
						.enumerate()
						.map(|(x, _x_view)| {
							let mut union: MP = Vec::<P>::new().into();
							for dx in 0..=1 {
								for dy in 0..=1 {
									if let Some(p) = reduced_map.get((y * 2 + dx, x * 2 + dy)) {
										let polygon: MP = p.clone().into();
										union = union.union(&polygon);
									}
								}
							}
							union.simplifyvw(&0.1)
						})
						.collect();
					polys
				})
				.collect();

			reduced_map = Array::from_shape_fn((h, w), |(y, x)| p[y][x].clone());
		}

		reduced_map[(0, 0)].simplifyvw(&0.1).into()
	}
}
