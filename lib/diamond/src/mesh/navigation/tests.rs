use crate::mesh::builder::MeshBuilder;
use crate::mesh::tests::*;
use crate::mesh::Mesh;
use geo::prelude::*;
use geo_types::*;
use itertools::*;
use plotters::style::colors::*;
use std::fs::File;
use std::io::BufReader;

struct Context {
	name: String,
	mesh: Mesh,
}

impl Context {
	fn new(name: &str) -> Self {
		let input_file = format!("test-data/{}-input.json", name);
		let input_map: InputMap = {
			let file = File::open(input_file).unwrap();
			let reader = BufReader::new(file);
			serde_json::from_reader(reader).unwrap()
		};

		let mut builder =
			MeshBuilder::new(input_map.num_tiles_x, input_map.num_tiles_y, 16, 16, 4.0);
		for polygon in input_map.polygons.iter() {
			builder.add_polygon(polygon.tile_x, polygon.tile_y, polygon.into());
		}
		let mesh = builder.build();

		Self {
			name: name.to_owned(),
			mesh,
		}
	}

	fn test_exhaustive_paths(&self) {
		let (top_left, bottom_right) = self.mesh.bounding_box();
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
			if self.mesh.collision.obstacles.contains(&from) {
				continue;
			}

			let to = Point::new(to_x as f32, to_y as f32);
			if self.mesh.collision.obstacles.contains(&to) {
				continue;
			}

			if let Some(path) = &self.mesh.navigation.compute_path(&from, &to) {
				self.validate_path(path, from, to);
			}
		}
	}

	fn test_specific_path(
		&self,
		from: Point<f32>,
		to: Point<f32>,
		expected_path: Option<LineString<f32>>,
	) {
		if let Some(path) = &expected_path {
			self.draw_test_case(Some((path, "expected", &from, &to)));
		}
		let path = self.mesh.navigation.compute_path(&from, &to);
		if let Some(path) = &path {
			self.draw_test_case(Some((path, "actual", &from, &to)));
			self.validate_path(path, from, to);
		}
		assert_eq!(path, expected_path);
	}

	fn validate_path(&self, path: &LineString<f32>, from: Point<f32>, to: Point<f32>) {
		assert!(path.num_coords() >= 2);
		assert_eq!(path[0], from.into());
		assert_eq!(path[path.num_coords() - 1], to.into());
		for line in path.lines() {
			if line.start_point() != from && line.end_point() != to {
				for polygon in &self.mesh.collision.obstacles.0 {
					// TODO this breaks when running tests with 0 navigation padding
					let intersects = polygon.intersects(&line);
					if intersects {
						self.draw_test_case(Some((path, "actual", &from, &to)));
					}
					assert!(!intersects);
				}
			}
		}
	}

	fn draw_test_case(&self, path: Option<(&LineString<f32>, &str, &Point<f32>, &Point<f32>)>) {
		let result_file = match path {
			None => format!("test-output/{}-navigation-mesh-actual.png", &self.name),
			Some((_, suffix, from, to)) => format!(
				"test-output/{}-path-from-({}, {})-to-({}, {})-{}.png",
				&self.name,
				from.x(),
				from.y(),
				to.x(),
				to.y(),
				suffix
			),
		};
		let mut mesh_painter = MeshPainter::new(&self.mesh, &result_file);
		mesh_painter.clear(&WHITE);

		// Draw collisions
		for contour in self.mesh.collision.get_contours() {
			mesh_painter.draw_line_string(&contour, &RED);
		}

		// Draw navigation
		let triangles = self.mesh.navigation.get_triangles();
		for triangle in triangles {
			let polygon = triangle.to_polygon();
			let line_string = polygon.exterior();
			mesh_painter.draw_line_string(line_string, &CYAN);
		}

		if let Some((path, _, _, _)) = path {
			mesh_painter.draw_line_string(path, &MAGENTA);
		}
	}
}

#[test]
fn empty() {
	let context = Context::new("empty");
	context.draw_test_case(None);
	context.test_specific_path(
		Point::new(10.0, 20.0),
		Point::new(40.0, 30.0),
		Some(line_string![(x: 10.0, y: 20.0), (x: 40.0, y: 30.0)]),
	);
}

#[test]
fn small() {
	let context = Context::new("small");
	context.draw_test_case(None);
	context.test_specific_path(
		Point::new(50.0, 35.0),
		Point::new(170.0, 35.0),
		Some(line_string![(x: 50.0, y: 35.0), (x: 170.0, y: 35.0)]),
	);
	context.test_specific_path(
		Point::new(40.0, 125.0),
		Point::new(410.0, 220.0),
		Some(line_string![(x: 40.0, y: 125.0), (x: 174.34326, y: 244.0), (x: 353.65674, y: 244.0), (x: 410.0, y: 220.0)]),
	);
	context.test_exhaustive_paths();
}

#[test]
fn large() {
	let context = Context::new("large");
	context.draw_test_case(None);
	context.test_specific_path(Point::new(300.0, 300.0), Point::new(450.0, 500.0), None);
	context.test_exhaustive_paths();
}
