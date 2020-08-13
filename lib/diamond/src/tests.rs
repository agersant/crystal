use crate::mesh::builder::MeshBuilder;
use crate::mesh::collision::CollisionMesh;
use geo_types::*;
use plotters::drawing::backend::DrawingBackend;
use plotters::drawing::BitMapBackend;
use plotters::style::colors::*;
use serde::Deserialize;
use std::fs::File;
use std::io::BufReader;

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
	num_tiles_x: i32,
	#[serde(rename(serialize = "numTilesY", deserialize = "numTilesY"))]
	num_tiles_y: i32,
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
				(padding as f32 - top_left.x() + line.start.x) as i32,
				(padding as f32 - top_left.y() + line.start.y) as i32,
			);
			backend.draw_circle(start_point, 2, &RED, true).unwrap();
			backend.draw_line(start_point, end_point, &RED).unwrap();
		}
	}
}

fn test_sample_files(name: &str) {
	let polygons_file = format!("test-data/{}-polygons.json", name);
	let input_map: TestInputMap = {
		let file = File::open(polygons_file).unwrap();
		let reader = BufReader::new(file);
		serde_json::from_reader(reader).unwrap()
	};

	let expected_collision_mesh_file = format!("test-data/{}-mesh.json", name);
	let expected_mesh = {
		let file = File::open(&expected_collision_mesh_file).unwrap();
		let reader = BufReader::new(file);
		let obstacles = serde_json::from_reader(reader).unwrap();
		CollisionMesh { obstacles }
	};

	let mut builder = MeshBuilder::new(input_map.num_tiles_x, input_map.num_tiles_y, 10.0, 10.0);
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

	let expected_result_file = format!("test-output/{}-expected.png", name);
	draw_mesh(&expected_mesh, &expected_result_file);

	let actual_result_file = format!("test-output/{}-result.png", name);
	draw_mesh(&mesh.collision, &actual_result_file);

	assert_eq!(mesh.collision, expected_mesh);
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
