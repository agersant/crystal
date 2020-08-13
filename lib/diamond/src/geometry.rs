use geo::algorithm::translate::Translate;
use geo_types::{Line, LineString, Point};
use itertools::Itertools;

fn line_intersection(a: &Line<f32>, b: &Line<f32>) -> Option<Point<f32>> {
	let x1 = a.start.x;
	let y1 = a.start.y;
	let x2 = a.end.x;
	let y2 = a.end.y;
	let x3 = b.start.x;
	let y3 = b.start.y;
	let x4 = b.end.x;
	let y4 = b.end.y;
	let det = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
	if det == 0.0 {
		None
	} else {
		let x = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / det;
		let y = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) / det;
		Some((x, y).into())
	}
}

fn normalize(point: &Point<f32>) -> Point<f32> {
	let length = (point.x() * point.x() + point.y() * point.y()).sqrt();
	if length == 0.0 {
		return point.clone();
	}
	Point::new(point.x() / length, point.y() / length)
}

pub trait LineStringExt {
	fn offset(&self, amount: f32) -> LineString<f32>;
	fn is_clockwise(&self) -> bool;
}

impl LineStringExt for LineString<f32> {
	fn is_clockwise(&self) -> bool {
		let mut sum = 0.0;
		for line in self.lines() {
			sum += (line.end.x - line.start.x) * (line.end.y + line.start.y);
		}
		sum > 0.0
	}

	fn offset(&self, amount: f32) -> LineString<f32> {
		let mut vertices: Vec<Point<f32>> = Vec::new();
		vertices.reserve(self.num_coords());

		let source_vertices = self.clone().into_points();
		let vertex_triplets = source_vertices
			.iter()
			.take(self.num_coords() - 1)
			.cycle()
			.tuple_windows()
			.take(self.num_coords() - 1);

		for (a, b, c) in vertex_triplets {
			let ab = Line::new((a.x(), a.y()), (b.x(), b.y()));
			let bc = Line::new((b.x(), b.y()), (c.x(), c.y()));
			let ab_normal = normalize(&Point::new(-ab.dy(), ab.dx()));
			let bc_normal = normalize(&Point::new(-bc.dy(), bc.dx()));

			// TODO use clockwise-ness instead of flipping normal arbitrarily
			let padded_ab = ab.translate(-ab_normal.x() * amount, -ab_normal.y() * amount);
			let padded_bc = bc.translate(-bc_normal.x() * amount, -bc_normal.y() * amount);
			let intersection = line_intersection(&padded_ab, &padded_bc).unwrap();
			vertices.push(intersection);
		}

		vertices.push(vertices[0].clone());
		vertices.into()
	}
}
