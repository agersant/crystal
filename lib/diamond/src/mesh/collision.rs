use crate::geometry::*;
use geo::algorithm::bounding_rect::BoundingRect;
use geo::algorithm::simplifyvw::SimplifyVW;
use geo_booleanop::boolean::BooleanOp;
#[cfg(test)]
use geo_types::polygon;
use ndarray::parallel::prelude::*;
use ndarray::Array;
use ndarray::Array2;
use ndarray::Axis;
use rayon::iter::IndexedParallelIterator;
use rayon::iter::IntoParallelIterator;

#[derive(Debug)]
pub struct CollisionMesh {
	pub obstacles: geo_types::MultiPolygon<f32>,
}

impl Default for CollisionMesh {
	fn default() -> Self {
		let polygons: Vec<geo_types::Polygon<f32>> = Vec::new();
		CollisionMesh {
			obstacles: polygons.into(),
		}
	}
}

impl PartialEq for CollisionMesh {
	fn eq(&self, other: &Self) -> bool {
		let xor = self.obstacles.xor(&other.obstacles);
		xor.bounding_rect().is_none()
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

		CollisionMesh {
			obstacles: reduced_map[(0, 0)].simplifyvw(&0.1),
		}
	}

	pub fn get_contours(&self) -> Vec<Polygon> {
		let mut polygons: Vec<Polygon> = Vec::new();
		let obstacles = self.obstacles.clone(); // TODO Find a way to iterate on multipolygon without cloning
		for polygon in obstacles {
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
		polygons
	}

	#[cfg(test)]
	pub fn bounding_box(&self) -> (Vertex, Vertex) {
		match self.obstacles.bounding_rect() {
			None => (Vertex { x: 0.0, y: 0.0 }, Vertex { x: 0.0, y: 0.0 }),
			Some(r) => (
				Vertex {
					x: r.min().x,
					y: r.min().y,
				},
				Vertex {
					x: r.max().x,
					y: r.max().y,
				},
			),
		}
	}
}

#[test]
fn compare_meshes_equal_trivially_different() {
	let a = CollisionMesh {
		obstacles: vec![polygon![
			(x: 16.0, y: 32.0),
			(x: 0.0, y: 0.0),
			(x: 128.0, y: 0.0),
			(x: 128.0, y: 16.0),
			(x: 16.0, y: 16.0),
			(x: 16.0, y: 32.0),
		]]
		.into(),
	};

	let b = CollisionMesh {
		obstacles: vec![polygon![
			(x: 20.0, y: 20.0),
			(x: 10.0, y: 20.0),
			(x: 10.0, y: 10.0),
			(x: 20.0, y: 20.0),
		]]
		.into(),
	};

	assert_ne!(a, b);
}

#[test]
fn compare_meshes_different_but_overlapping() {
	let a = CollisionMesh {
		obstacles: vec![polygon![
			(x: 0.0, y: 0.0),
			(x: 10.0, y: 0.0),
			(x: 10.0, y: 10.0),
			(x: 0.0, y: 10.0),
			(x: 0.0, y: 0.0),
		]]
		.into(),
	};

	let b = CollisionMesh {
		obstacles: vec![polygon![
			(x: 0.0, y: 0.0),
			(x: 20.0, y: 0.0),
			(x: 20.0, y: 10.0),
			(x: 0.0, y: 10.0),
			(x: 0.0, y: 0.0),
		]]
		.into(),
	};

	assert_ne!(a, b);
}

#[test]
fn compare_meshes_cycled_vertices_and_polygons() {
	let a = CollisionMesh {
		obstacles: vec![
			polygon![
				(x: 16.0, y: 32.0),
				(x: 0.0, y: 0.0),
				(x: 128.0, y: 0.0),
				(x: 128.0, y: 16.0),
				(x: 16.0, y: 16.0),
				(x: 16.0, y: 32.0),
			],
			polygon![
				(x: 10.0, y: 10.0),
				(x: 20.0, y: 20.0),
				(x: 10.0, y: 20.0),
				(x: 10.0, y: 10.0),
			],
		]
		.into(),
	};

	let b = CollisionMesh {
		obstacles: vec![
			polygon![
				(x: 20.0, y: 20.0),
				(x: 10.0, y: 20.0),
				(x: 10.0, y: 10.0),
				(x: 20.0, y: 20.0),
			],
			polygon![
				(x: 0.0, y: 0.0),
				(x: 128.0, y: 0.0),
				(x: 128.0, y: 16.0),
				(x: 16.0, y: 16.0),
				(x: 16.0, y: 32.0),
				(x: 0.0, y: 0.0),
			],
		]
		.into(),
	};

	assert_eq!(a, b);
}
