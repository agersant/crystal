use geo::prelude::*;
use geo_types::{Line, LineString, Point};
use itertools::Itertools;
use spade::delaunay::*;

#[cfg(test)]
mod tests;

pub trait PointExt {
	fn length(&self) -> f32;
	fn normal(&self, direction: &NormalDirection) -> Point<f32>;
	fn normalize(&self) -> Point<f32>;
}

impl PointExt for Point<f32> {
	fn length(&self) -> f32 {
		(self.x() * self.x() + self.y() * self.y()).sqrt()
	}

	fn normal(&self, direction: &NormalDirection) -> Point<f32> {
		match direction {
			NormalDirection::Left => Point::new(-self.y(), self.x()),
			NormalDirection::Right => Point::new(self.y(), -self.x()),
		}
	}

	fn normalize(&self) -> Point<f32> {
		let length = self.length();
		if length > 0.0 {
			Point::new(self.x() / length, self.y() / length)
		} else {
			self.clone()
		}
	}
}

pub enum NormalDirection {
	Left,
	#[allow(dead_code)]
	Right,
}

pub trait LineExt {
	fn length(&self) -> f32;
	fn intersection(&self, other: &Line<f32>) -> Option<Point<f32>>;
	fn normal(&self, direction: &NormalDirection) -> Point<f32>;
}

impl LineExt for Line<f32> {
	fn length(&self) -> f32 {
		(self.dx() * self.dx() + self.dy() * self.dy()).sqrt()
	}

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

	fn normal(&self, direction: &NormalDirection) -> Point<f32> {
		Point::new(self.dx(), self.dy())
			.normal(direction)
			.normalize()
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
		let amount = if self.is_clockwise() { amount } else { -amount };

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

			let ab_normal = ab.normal(&NormalDirection::Left);
			let bc_normal = bc.normal(&NormalDirection::Left);

			let padded_ab = ab.translate(ab_normal.x() * amount, ab_normal.y() * amount);
			let padded_bc = bc.translate(bc_normal.x() * amount, bc_normal.y() * amount);

			let intersection = padded_ab.intersection(&padded_bc).unwrap();
			vertices.push(intersection);
		}

		vertices.push(vertices[0].clone());
		vertices.into()
	}
}

pub trait FaceHandleExt {
	fn center(self) -> Point<f32>;
}

impl FaceHandleExt for &FaceHandle<'_, [f32; 2], CdtEdge> {
	fn center(self) -> Point<f32> {
		let triangle = self.as_triangle();
		let x = (triangle[0][0] + triangle[1][0] + triangle[2][0]) / 3.0;
		let y = (triangle[0][1] + triangle[1][1] + triangle[2][1]) / 3.0;
		Point::new(x, y)
	}
}
