use crate::mesh::builder::MeshBuilder;
use crate::mesh::navigation::*;
use crate::mesh::tests::*;
use crate::mesh::*;
use plotters::style::colors::*;
use std::fs::File;
use std::io::BufReader;

fn draw_path(mesh: &Mesh, path: &LineString<f32>, out_file: &str) {
	let (top_left, bottom_right) = mesh.bounding_box();
	let width = (bottom_right.x() - top_left.x()).abs().ceil() as u32;
	let height = (bottom_right.y() - top_left.x()).abs().ceil() as u32;
	let mut draw_surface = DrawSurface::new(out_file, width, height, top_left);
	draw_surface.clear(&WHITE);

	// Draw collisions
	for contour in mesh.collision.get_contours() {
		draw_surface.draw_line_string(&contour, &RED);
	}

	// Draw navigation
	let triangles = mesh.navigation.get_triangles();
	for triangle in triangles {
		let polygon = triangle.to_polygon();
		let line_string = polygon.exterior();
		draw_surface.draw_line_string(line_string, &CYAN);
	}

	// Draw path
	draw_surface.draw_line_string(path, &MAGENTA);
}

fn run_test_case(name: &str, from: &Point<f32>, to: &Point<f32>) {
	let input_file = format!("test-data/{}-input.json", name);
	let input_map: InputMap = {
		let file = File::open(input_file).unwrap();
		let reader = BufReader::new(file);
		serde_json::from_reader(reader).unwrap()
	};

	let mut builder = MeshBuilder::new(input_map.num_tiles_x, input_map.num_tiles_y, 16, 16, 4.0);
	for polygon in input_map.polygons.iter() {
		builder.add_polygon(polygon.tile_x, polygon.tile_y, polygon.into());
	}

	let start = std::time::SystemTime::now();
	let mesh = builder.build();
	let path = mesh.navigation.compute_path(from, to);
	println!(
		"{} took {:?}",
		name,
		std::time::SystemTime::now().duration_since(start).unwrap()
	);

	std::fs::create_dir_all("test-output").unwrap();

	let actual_result_file = format!("test-output/{}-pathing.png", name);
	draw_path(&mesh, &path, &actual_result_file);

	// TODO assertions on path validity
}

#[test]
fn small() {
	run_test_case("small", &Point::new(165.0, 48.0), &Point::new(300.0, 258.0));
}

#[test]
fn large() {
	run_test_case(
		"large",
		&Point::new(105.0, 450.0),
		&Point::new(820.0, 405.0),
	);
}
