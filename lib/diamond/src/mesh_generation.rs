use crate::types::*;
use geo::algorithm::simplify::Simplify;
use geo_booleanop::boolean::BooleanOp;

pub fn generate_mesh(polygons: &[Polygon]) -> CollisionMesh {
	let mut union_result: geo_types::MultiPolygon<f32> =
		Vec::<geo_types::Polygon<f32>>::new().into();

	for p in polygons.iter() {
		let polygon = geo_types::Polygon::<f32>::new(
			geo_types::LineString::from(
				p.vertices
					.iter()
					.map(|v| (v.x, v.y))
					.collect::<Vec<(f32, f32)>>(),
			),
			vec![],
		);
		union_result = union_result.union(&polygon);
	}
	union_result = union_result.simplify(&0.5);

	union_result.into()
}

#[test]
fn empty_map() {
	let polygons = Vec::new();
	let mesh = generate_mesh(&polygons);
	assert_eq!(mesh.chains.len(), 0);
}

#[test]
fn single_square() {
	let polygons = vec![Polygon {
		vertices: {
			vec![
				Vertex { x: 10.0, y: 10.0 },
				Vertex { x: 20.0, y: 10.0 },
				Vertex { x: 20.0, y: 20.0 },
				Vertex { x: 10.0, y: 20.0 },
			]
		},
	}];
	let mesh = generate_mesh(&polygons);
	assert_eq!(mesh.chains.len(), 1);
}

#[test]
fn simple_merge() {
	let polygons = vec![
		Polygon {
			vertices: {
				vec![
					Vertex { x: 10.0, y: 10.0 },
					Vertex { x: 20.0, y: 10.0 },
					Vertex { x: 20.0, y: 20.0 },
					Vertex { x: 10.0, y: 20.0 },
				]
			},
		},
		Polygon {
			vertices: {
				vec![
					Vertex { x: 20.0, y: 10.0 },
					Vertex { x: 30.0, y: 10.0 },
					Vertex { x: 30.0, y: 20.0 },
					Vertex { x: 20.0, y: 20.0 },
				]
			},
		},
	];
	let mesh = generate_mesh(&polygons);
	assert_eq!(mesh.chains.len(), 1);
}

#[test]
fn overlap_merge() {
	let polygons = vec![
		Polygon {
			vertices: {
				vec![
					Vertex { x: 10.0, y: 10.0 },
					Vertex { x: 20.0, y: 10.0 },
					Vertex { x: 20.0, y: 20.0 },
					Vertex { x: 10.0, y: 20.0 },
				]
			},
		},
		Polygon {
			vertices: {
				vec![
					Vertex { x: 15.0, y: 5.0 },
					Vertex { x: 25.0, y: 5.0 },
					Vertex { x: 25.0, y: 15.0 },
					Vertex { x: 15.0, y: 15.0 },
				]
			},
		},
	];
	let mesh = generate_mesh(&polygons);
	assert_eq!(mesh.chains.len(), 1);
	assert_eq!(mesh.chains[0].vertices.len(), 9);
}

#[test]
fn non_merge() {
	let polygons = vec![
		Polygon {
			vertices: {
				vec![
					Vertex { x: 10.0, y: 10.0 },
					Vertex { x: 20.0, y: 10.0 },
					Vertex { x: 20.0, y: 20.0 },
					Vertex { x: 10.0, y: 20.0 },
				]
			},
		},
		Polygon {
			vertices: {
				vec![
					Vertex { x: 30.0, y: 10.0 },
					Vertex { x: 40.0, y: 10.0 },
					Vertex { x: 40.0, y: 20.0 },
					Vertex { x: 30.0, y: 20.0 },
				]
			},
		},
	];
	let mesh = generate_mesh(&polygons);
	assert_eq!(mesh.chains.len(), 2);
}
