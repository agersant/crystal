use geo::algorithm::translate::Translate;
use geo_types::{Line, LineString, Point};
use itertools::Itertools;

pub trait PointExt {
	fn length(&self) -> f32;
	fn normal(&self) -> Point<f32>;
	fn normalize(&mut self);
}

impl PointExt for Point<f32> {
	fn length(&self) -> f32 {
		(self.x() * self.x() + self.y() * self.y()).sqrt()
	}

	fn normal(&self) -> Point<f32> {
		Point::new(-self.y(), self.x())
	}

	fn normalize(&mut self) {
		let length = self.length();
		if length > 0.0 {
			self.set_x(self.x() / length);
			self.set_y(self.y() / length);
		}
	}
}

pub trait LineExt {
	fn intersection(&self, other: &Line<f32>) -> Option<Point<f32>>;
	fn normal(&self) -> Point<f32>;
}

impl LineExt for Line<f32> {
	fn intersection(&self, other: &Line<f32>) -> Option<Point<f32>> {
		let x1 = self.start.x;
		let y1 = self.start.y;
		let x2 = self.end.x;
		let y2 = self.end.y;
		let x3 = other.start.x;
		let y3 = other.start.y;
		let x4 = other.end.x;
		let y4 = other.end.y;
		let det = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
		if det == 0.0 {
			None
		} else {
			let x = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / det;
			let y = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) / det;
			Some((x, y).into())
		}
	}

	fn normal(&self) -> Point<f32> {
		let mut normal = Point::new(self.dx(), self.dy()).normal();
		normal.normalize();
		normal
	}
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
			let ab_normal = ab.normal();
			let bc_normal = bc.normal();

			// TODO use clockwise-ness instead of flipping normal arbitrarily
			let padded_ab = ab.translate(-ab_normal.x() * amount, -ab_normal.y() * amount);
			let padded_bc = bc.translate(-bc_normal.x() * amount, -bc_normal.y() * amount);
			let intersection = padded_ab.intersection(&padded_bc).unwrap();
			vertices.push(intersection);
		}

		vertices.push(vertices[0].clone());
		vertices.into()
	}
}
