use crate::mesh::builder::MeshBuilder;
use crate::mesh::tests::*;
use crate::mesh::Mesh;
use geo::prelude::*;
use geo_types::*;
use itertools::*;
use plotters::style::colors::*;
use std::fs::File;
use std::io::BufReader;

fn draw_test_case(name: &str, mesh: &Mesh, path: Option<&LineString<f32>>) {
	let result_file = match path {
		None => format!("test-output/{}-navigation-mesh-actual.png", name),
		Some(path) => {
			let from = path[0];
			let to = path[path.num_coords() - 1];
			format!(
				"test-output/{}-path-from-({}, {})-to-({}, {}).png",
				name, from.x, from.y, to.x, to.y
			)
		}
	};
	let mut mesh_painter = MeshPainter::new(mesh, &result_file);
	mesh_painter.clear(&WHITE);

	// Draw collisions
	for contour in mesh.collision.get_contours() {
		mesh_painter.draw_line_string(&contour, &RED);
	}

	// Draw navigation
	let triangles = mesh.navigation.get_triangles();
	for triangle in triangles {
		let polygon = triangle.to_polygon();
		let line_string = polygon.exterior();
		mesh_painter.draw_line_string(line_string, &CYAN);
	}

	if let Some(path) = path {
		mesh_painter.draw_line_string(&path, &MAGENTA);
	}
}

fn run_test_case(name: &str) {
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

	let mesh = builder.build();
	draw_test_case(name, &mesh, None);

	// Test many paths
	let (top_left, bottom_right) = mesh.bounding_box();
	let x_min = top_left.x() as i32;
	let y_min = top_left.y() as i32;
	let x_max = bottom_right.x() as i32;
	let y_max = bottom_right.y() as i32;
	let num_steps = 15;
	let step_x = ((x_max - x_min) / num_steps) as usize;
	let step_y = ((y_max - y_min) / num_steps) as usize;

	for (from_x, from_y, to_x, to_y) in iproduct!(
		(x_min..=x_max).step_by(step_x),
		(y_min..=y_max).step_by(step_y),
		(x_min..=x_max).step_by(step_x),
		(y_min..=y_max).step_by(step_y)
	) {
		let from = Point::new(from_x as f32, from_y as f32);
		if mesh.collision.obstacles.contains(&from) {
			continue;
		}

		let to = Point::new(to_x as f32, to_y as f32);
		if mesh.collision.obstacles.contains(&to) {
			continue;
		}

		if let Some(path) = mesh.navigation.compute_path(&from, &to) {
			assert!(path.num_coords() >= 2);
			assert_eq!(path[0], from.into());
			assert_eq!(path[path.num_coords() - 1], to.into());
			for line in path.lines() {
				if line.start_point() != from && line.end_point() != to {
					for polygon in &mesh.collision.obstacles.0 {
						let intersects = polygon.intersects(&line);
						if intersects {
							draw_test_case(name, &mesh, Some(&path));
						}
						assert!(!intersects);
					}
				}
			}
		}
	}
}

#[test]
fn small() {
	run_test_case("small");
}

#[test]
fn large() {
	run_test_case("large");
}
