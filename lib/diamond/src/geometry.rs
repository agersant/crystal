use geo::algorithm::translate::Translate;
use geo_types::{Line, Point};
use itertools::Itertools;

#[derive(Clone, Debug)]
pub struct Vertex {
	pub x: f32,
	pub y: f32,
}

impl From<&geo_types::Point<f32>> for Vertex {
	fn from(point: &geo_types::Point<f32>) -> Vertex {
		Vertex {
			x: point.x(),
			y: point.y(),
		}
	}
}

impl From<&Vertex> for geo_types::Point<f32> {
	fn from(vertex: &Vertex) -> geo_types::Point<f32> {
		(vertex.x, vertex.y).into()
	}
}

#[derive(Clone, Debug)]
pub struct Polygon {
	// TODO replace with geo::LineString
	// TODO enforce closed-ness or not consistently
	pub vertices: Vec<Vertex>,
}

impl From<&Polygon> for geo_types::Polygon<f32> {
	fn from(polygon: &Polygon) -> geo_types::Polygon<f32> {
		geo_types::Polygon::<f32>::new(
			geo_types::LineString::from(
				polygon
					.vertices
					.iter()
					.map(|v| (v.x as f32, v.y as f32))
					.collect::<Vec<(f32, f32)>>(),
			),
			vec![],
		)
	}
}

impl From<&geo_types::LineString<f32>> for Polygon {
	fn from(line_string: &geo_types::LineString<f32>) -> Polygon {
		let vertices = line_string.points_iter().map(|v| (&v).into()).collect();
		Polygon { vertices }
	}
}

impl From<&Polygon> for geo_types::LineString<f32> {
	fn from(polygon: &Polygon) -> geo_types::LineString<f32> {
		let points: Vec<(f32, f32)> = polygon.vertices.iter().map(|v| (v.x, v.y)).collect();
		points.into()
	}
}

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

impl Polygon {
	pub fn edges(&self) -> impl Iterator<Item = (&Vertex, &Vertex)> {
		let num_vertices = self.vertices.len();
		self.vertices
			.iter()
			.take(num_vertices - 1)
			.cycle()
			.tuple_windows()
			.take(num_vertices - 1)
	}

	pub fn is_clockwise(&self) -> bool {
		let mut sum = 0.0;
		for (a, b) in self.edges() {
			sum += (b.x - a.x) * (b.y + a.y);
		}
		sum > 0.0
	}

	fn vertex_triplets(&self) -> impl Iterator<Item = (&Vertex, &Vertex, &Vertex)> {
		let num_vertices = self.vertices.len();
		self.vertices
			.iter()
			.take(num_vertices - 1)
			.cycle()
			.tuple_windows()
			.take(num_vertices - 1)
	}

	pub fn offset(&self, amount: f32) -> Polygon {
		let mut vertices: Vec<Vertex> = Vec::new();
		vertices.reserve(self.vertices.len());
		for (a, b, c) in self.vertex_triplets() {
			let ab = Line::new((a.x, a.y), (b.x, b.y));
			let bc = Line::new((b.x, b.y), (c.x, c.y));
			let ab_normal = normalize(&Point::new(-ab.dy(), ab.dx()));
			let bc_normal = normalize(&Point::new(-bc.dy(), bc.dx()));

			// TODO use clockwise-ness instead of flipping normal arbitrarily
			let padded_ab = ab.translate(-ab_normal.x() * amount, -ab_normal.y() * amount);
			let padded_bc = bc.translate(-bc_normal.x() * amount, -bc_normal.y() * amount);
			let intersection = line_intersection(&padded_ab, &padded_bc).unwrap();
			vertices.push((&intersection).into());
		}
		vertices.push(vertices[0].clone());
		Polygon { vertices }
	}
}
