use crate::mesh::builder::MeshBuilder;
use crate::mesh::collision::*;
use plotters::drawing::backend::DrawingBackend;
use plotters::drawing::BitMapBackend;
use plotters::style::colors::*;
use serde::Deserialize;
use std::fs::File;
use std::io::BufReader;

fn draw_mesh(mesh: &CollisionMesh, out_file: &str) {
	let (mut top_left, mut bottom_right) = mesh.bounding_box();
	if top_left.x().is_infinite() || top_left.x().is_nan() {
		top_left.set_x(0.0);
	}
	if top_left.y().is_infinite() || top_left.y().is_nan() {
		top_left.set_y(0.0);
	}
	if bottom_right.x().is_infinite() || bottom_right.x().is_nan() {
		bottom_right.set_x(100.0);
	}
	if bottom_right.y().is_infinite() || bottom_right.y().is_nan() {
		bottom_right.set_y(100.0);
	}
	let padding = 20;
	let width = 2 * padding + (bottom_right.x() - top_left.x()).abs().ceil() as u32;
	let height = 2 * padding + (bottom_right.y() - top_left.x()).abs().ceil() as u32;

	let mut backend = BitMapBackend::new(out_file, (width, height));
	backend
		.draw_rect((0, 0), (width as i32 - 1, height as i32 - 1), &WHITE, true)
		.unwrap();

	let contours = mesh.get_contours();
	for contour in &contours {
		for line in contour.lines() {
			let start_point = (
				(padding as f32 - top_left.x() + line.start.x) as i32,
				(padding as f32 - top_left.y() + line.start.y) as i32,
			);
			let end_point = (
				(padding as f32 - top_left.x() + line.end.x) as i32,
				(padding as f32 - top_left.y() + line.end.y) as i32,
			);
			backend.draw_circle(start_point, 2, &RED, true).unwrap();
			backend.draw_line(start_point, end_point, &RED).unwrap();
		}
	}
}

#[derive(Debug, Deserialize)]
struct TestInputVertex {
	x: f32,
	y: f32,
}

#[derive(Debug, Deserialize)]
struct TestInputPolygon {
	#[serde(rename(serialize = "tileX", deserialize = "tileX"))]
	tile_x: i32,
	#[serde(rename(serialize = "tileY", deserialize = "tileY"))]
	tile_y: i32,
	vertices: Vec<TestInputVertex>,
}

#[derive(Debug, Deserialize)]
struct TestInputMap {
	#[serde(rename(serialize = "numTilesX", deserialize = "numTilesX"))]
	num_tiles_x: u32,
	#[serde(rename(serialize = "numTilesY", deserialize = "numTilesY"))]
	num_tiles_y: u32,
	polygons: Vec<TestInputPolygon>,
}

#[derive(Debug, Deserialize)]
struct TestInputMesh(Vec<Vec<TestInputVertex>>);

impl From<&TestInputVertex> for Point<f32> {
	fn from(input: &TestInputVertex) -> Point<f32> {
		Point::new(input.x, input.y)
	}
}

impl From<&TestInputPolygon> for LineString<f32> {
	fn from(input: &TestInputPolygon) -> LineString<f32> {
		LineString::from(
			input
				.vertices
				.iter()
				.map(|v| v.into())
				.collect::<Vec<Point<f32>>>(),
		)
	}
}

fn test_sample_files(name: &str) {
	let input_file = format!("test-data/{}-input.json", name);
	let input_map: TestInputMap = {
		let file = File::open(input_file).unwrap();
		let reader = BufReader::new(file);
		serde_json::from_reader(reader).unwrap()
	};

	let expected_collision_mesh_file = format!("test-data/{}-collision-mesh.json", name);
	let expected_mesh = {
		let file = File::open(&expected_collision_mesh_file).unwrap();
		let reader = BufReader::new(file);
		let obstacles = serde_json::from_reader(reader).unwrap();
		CollisionMesh { obstacles }
	};

	let mut builder = MeshBuilder::new(input_map.num_tiles_x, input_map.num_tiles_y, 10, 10, 1.0);
	for polygon in input_map.polygons.iter() {
		builder.add_polygon(polygon.tile_x, polygon.tile_y, polygon.into());
	}

	let start = std::time::SystemTime::now();
	let mesh = builder.build();
	println!(
		"{} took {:?}",
		name,
		std::time::SystemTime::now().duration_since(start).unwrap()
	);

	std::fs::create_dir_all("test-output").unwrap();

	let expected_result_file = format!("test-output/{}-collision-mesh-expected.png", name);
	draw_mesh(&expected_mesh, &expected_result_file);

	let actual_result_file = format!("test-output/{}-collision-mesh-actual.png", name);
	draw_mesh(&mesh.collision, &actual_result_file);

	assert_eq!(mesh.collision, expected_mesh);
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

#[test]
fn trivial() {
	test_sample_files("trivial");
}

#[test]
fn small() {
	test_sample_files("small");
}

#[test]
fn large() {
	test_sample_files("large");
}

#[test]
fn overlap() {
	test_sample_files("overlap");
}

#[test]
fn asymetric_collapse() {
	test_sample_files("asymetric-collapse");
}
