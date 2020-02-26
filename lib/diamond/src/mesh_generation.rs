use crate::types::*;
use array2d::Array2D;
use geo::algorithm::simplifyvw::SimplifyVW;
use geo_booleanop::boolean::BooleanOp;

#[derive(Debug)]
pub struct CollisionMeshBuilder {
	polygons: Array2D<Vec<geo_types::Polygon<f32>>>,
	map_width: usize,
	map_height: usize,
}

impl CollisionMeshBuilder {
	pub fn new() -> CollisionMeshBuilder {
		CollisionMeshBuilder {
			// TODO map width and height as input
			polygons: Array2D::filled_with(Vec::<geo_types::Polygon<f32>>::new(), 17, 30),
			map_width: 30,
			map_height: 17,
		}
	}

	pub fn add_polygon(&mut self, polygon: Polygon) {
		if polygon.vertices.len() == 0 {
			return;
		}
		// TODO x and y as input
		let x = (polygon
			.vertices
			.iter()
			.min_by_key(|v| v.x.floor() as i32)
			.unwrap()
			.x / 16.0)
			.floor() as usize;
		let y = (polygon
			.vertices
			.iter()
			.min_by_key(|v| v.y.floor() as i32)
			.unwrap()
			.y / 16.0)
			.floor() as usize;
		self.polygons[(y, x)].push((&polygon).into());
	}

	pub fn build(&self) -> CollisionMesh {
		let mut w = self.map_width;
		let mut h = self.map_height;

		let mut reduced_map: Array2D<geo_types::MultiPolygon<f32>> =
			Array2D::filled_with(Vec::<geo_types::Polygon<f32>>::new().into(), h, w);
		for y in 0..h {
			for x in 0..w {
				reduced_map
					.set(y, x, self.polygons[(y, x)].clone().into())
					.unwrap();
			}
		}

		while w > 1 && h > 1 {
			w = (w as f32 / 2.0).ceil() as usize;
			h = (h as f32 / 2.0).ceil() as usize;
			let mut new_map =
				Array2D::filled_with(Vec::<geo_types::Polygon<f32>>::new().into(), h, w);

			// TODO rayon tf out of this
			for y in 0..h {
				for x in 0..w {
					let mut union: geo_types::MultiPolygon<f32> =
						Vec::<geo_types::Polygon<f32>>::new().into();
					for dx in 0..=1 {
						for dy in 0..=1 {
							if let Some(p) = reduced_map.get(y * 2 + dx, x * 2 + dy) {
								let polygon: geo_types::MultiPolygon<f32> = p.clone().into();
								union = union.union(&polygon);
							}
						}
					}

					union = union.simplifyvw(&0.1);
					new_map.set(y, x, union).unwrap();
				}
			}

			reduced_map = new_map;
		}

		(reduced_map[(0, 0)].clone()).simplifyvw(&0.1).into()
	}
}
