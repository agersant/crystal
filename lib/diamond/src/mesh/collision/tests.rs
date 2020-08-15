use crate::mesh::builder::MeshBuilder;
use crate::mesh::collision::*;
use crate::mesh::tests::*;
use plotters::drawing::backend::DrawingBackend;
use plotters::drawing::BitMapBackend;
use plotters::style::colors::*;
use serde::Deserialize;
use std::fs::File;
use std::io::BufReader;

fn draw_collision_mesh(mesh: &CollisionMesh, out_file: &str) {
	let (top_left, bottom_right) = mesh.bounding_box();
	let width = (bottom_right.x() - top_left.x()).abs().ceil() as u32;
	let height = (bottom_right.y() - top_left.x()).abs().ceil() as u32;
	let mut draw_surface = DrawSurface::new(out_file, width, height, top_left);
	draw_surface.clear(&WHITE);

	let mut backend = BitMapBackend::new(out_file, (width, height));
	backend
		.draw_rect((0, 0), (width as i32 - 1, height as i32 - 1), &WHITE, true)
		.unwrap();

	for contour in mesh.get_contours() {
		draw_surface.draw_line_string(&contour, &RED);
	}
}

#[derive(Debug, Deserialize)]
struct InputMesh(Vec<Vec<InputVertex>>);

impl From<&InputVertex> for Point<f32> {
	fn from(input: &InputVertex) -> Point<f32> {
		Point::new(input.x, input.y)
	}
}

impl From<&InputPolygon> for LineString<f32> {
	fn from(input: &InputPolygon) -> LineString<f32> {
		LineString::from(
			input
				.vertices
				.iter()
				.map(|v| v.into())
				.collect::<Vec<Point<f32>>>(),
		)
	}
}

fn run_test_case(name: &str) {
	let input_file = format!("test-data/{}-input.json", name);
	let input_map: InputMap = {
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
	draw_collision_mesh(&expected_mesh, &expected_result_file);

	let actual_result_file = format!("test-output/{}-collision-mesh-actual.png", name);
	draw_collision_mesh(&mesh.collision, &actual_result_file);

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
	run_test_case("trivial");
}

#[test]
fn small() {
	run_test_case("small");
}

#[test]
fn large() {
	run_test_case("large");
}

#[test]
fn overlap() {
	run_test_case("overlap");
}

#[test]
fn asymetric_collapse() {
	run_test_case("asymetric-collapse");
}
