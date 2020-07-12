use crate::geometry::*;
use geo::algorithm::simplifyvw::SimplifyVW;
use geo_booleanop::boolean::BooleanOp;
use ndarray::parallel::prelude::*;
use ndarray::Array;
use ndarray::Array2;
use ndarray::Axis;
use rayon::iter::IndexedParallelIterator;
use rayon::iter::IntoParallelIterator;
use std::collections::HashSet;

#[derive(Debug)]
pub struct CollisionMesh {
	pub polygons: Vec<Polygon>,
}

impl PartialEq for CollisionMesh {
	fn eq(&self, other: &Self) -> bool {
		if self.polygons.len() != other.polygons.len() {
			return false;
		}
		let self_polygons: HashSet<Polygon> = self.polygons.iter().cloned().collect();
		let other_polygons: HashSet<Polygon> = other.polygons.iter().cloned().collect();
		self_polygons == other_polygons
	}
}

impl From<geo_types::MultiPolygon<f32>> for CollisionMesh {
	fn from(multi_polygon: geo_types::MultiPolygon<f32>) -> CollisionMesh {
		let mut polygons: Vec<Polygon> = Vec::new();
		for polygon in multi_polygon.into_iter() {
			polygons.push(Polygon {
				vertices: polygon
					.exterior()
					.points_iter()
					.into_iter()
					.map(|p| Vertex { x: p.x(), y: p.y() })
					.collect::<Vec<Vertex>>(),
			});
			for interior in polygon.interiors().iter() {
				polygons.push(Polygon {
					vertices: interior
						.points_iter()
						.into_iter()
						.map(|p| Vertex { x: p.x(), y: p.y() })
						.collect::<Vec<Vertex>>(),
				});
			}
		}
		CollisionMesh { polygons }
	}
}

impl CollisionMesh {
	pub fn build(
		num_tiles_x: usize,
		num_tiles_y: usize,
		polygons: &Array2<Vec<geo_types::Polygon<f32>>>,
	) -> CollisionMesh {
		type P = geo_types::Polygon<f32>;
		type MP = geo_types::MultiPolygon<f32>;

		let mut w = num_tiles_x;
		let mut h = num_tiles_y;

		// Initial state
		let mut reduced_map: Array2<MP> =
			Array::from_shape_fn((h, w), |(y, x)| polygons[(y, x)].clone().into());

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

	#[cfg(test)]
	pub fn bounding_box(&self) -> (Vertex, Vertex) {
		let mut top_left = Vertex {
			x: std::f32::INFINITY,
			y: std::f32::INFINITY,
		};

		let mut bottom_right = Vertex {
			x: std::f32::NEG_INFINITY,
			y: std::f32::NEG_INFINITY,
		};

		for polygon in self.polygons.iter() {
			for vertex in polygon.vertices.iter() {
				top_left.x = vertex.x.min(top_left.x);
				top_left.y = vertex.y.min(top_left.y);
				bottom_right.x = vertex.x.max(bottom_right.x);
				bottom_right.y = vertex.y.max(bottom_right.y);
			}
		}

		(top_left, bottom_right)
	}
}

#[test]
fn meshes_equal() {
	let a = CollisionMesh {
		polygons: vec![
			Polygon {
				vertices: vec![
					Vertex { x: 16.0, y: 32.0 },
					Vertex { x: 0.0, y: 0.0 },
					Vertex { x: 128.0, y: 0.0 },
					Vertex { x: 128.0, y: 16.0 },
					Vertex { x: 16.0, y: 16.0 },
					Vertex { x: 16.0, y: 32.0 },
				],
			},
			Polygon {
				vertices: vec![
					Vertex { x: 10.0, y: 10.0 },
					Vertex { x: 20.0, y: 20.0 },
					Vertex { x: 10.0, y: 20.0 },
					Vertex { x: 10.0, y: 10.0 },
				],
			},
		],
	};
	let b = CollisionMesh {
		polygons: vec![
			Polygon {
				vertices: vec![
					Vertex { x: 20.0, y: 20.0 },
					Vertex { x: 10.0, y: 20.0 },
					Vertex { x: 10.0, y: 10.0 },
					Vertex { x: 20.0, y: 20.0 },
				],
			},
			Polygon {
				vertices: vec![
					Vertex { x: 0.0, y: 0.0 },
					Vertex { x: 128.0, y: 0.0 },
					Vertex { x: 128.0, y: 16.0 },
					Vertex { x: 16.0, y: 16.0 },
					Vertex { x: 16.0, y: 32.0 },
					Vertex { x: 0.0, y: 0.0 },
				],
			},
		],
	};
	assert_eq!(a, b);
}
