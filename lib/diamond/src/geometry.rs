use std::cmp::Ordering;
use std::collections::HashSet;
use std::hash::{Hash, Hasher};

#[derive(Clone, Debug)]
pub struct Vertex {
	pub x: f32,
	pub y: f32,
}

const PRECISION: f32 = 1.0 / 10_000.0;

impl PartialEq for Vertex {
	fn eq(&self, other: &Self) -> bool {
		let epsilon = PRECISION;
		(self.x - other.x).abs() < epsilon && (self.y - other.y).abs() < epsilon
	}
}

impl Eq for Vertex {}

impl Ord for Vertex {
	fn cmp(&self, other: &Self) -> Ordering {
		let x_cmp = self.x.partial_cmp(&other.x).unwrap_or(Ordering::Equal);
		if x_cmp != Ordering::Equal {
			x_cmp
		} else {
			self.y.partial_cmp(&other.y).unwrap_or(Ordering::Equal)
		}
	}
}

impl PartialOrd for Vertex {
	fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
		Some(self.cmp(other))
	}
}

impl Hash for Vertex {
	fn hash<H: Hasher>(&self, state: &mut H) {
		((self.x / PRECISION).floor() as i32).hash(state);
		((self.y / PRECISION).floor() as i32).hash(state);
	}
}

#[derive(Clone, Debug)]
pub struct Polygon {
	pub vertices: Vec<Vertex>,
}

impl PartialEq for Polygon {
	fn eq(&self, other: &Self) -> bool {
		if self.vertices.len() != other.vertices.len() {
			return false;
		}
		let self_vertices: HashSet<Vertex> = self.vertices.iter().cloned().collect();
		let other_vertices: HashSet<Vertex> = other.vertices.iter().cloned().collect();
		self_vertices == other_vertices
	}
}

impl Eq for Polygon {}

impl Hash for Polygon {
	fn hash<H: Hasher>(&self, state: &mut H) {
		if self.vertices.len() > 0 {
			assert!(self.vertices.len() > 1);
			assert_eq!(self.vertices.first(), self.vertices.last());
		}
		let mut sorted_vertices: Vec<&Vertex> =
			self.vertices.iter().take(self.vertices.len() - 1).collect();
		sorted_vertices.sort();
		sorted_vertices.hash(state);
	}
}

impl Ord for Polygon {
	fn cmp(&self, other: &Self) -> Ordering {
		if self.vertices.len() < other.vertices.len() {
			Ordering::Less
		} else if self.vertices.len() > other.vertices.len() {
			Ordering::Greater
		} else {
			let mut self_sorted_vertices = self.vertices.clone();
			let mut other_sorted_vertices = other.vertices.clone();
			self_sorted_vertices.sort();
			other_sorted_vertices.sort();
			for (i, vertex) in self_sorted_vertices.iter().enumerate() {
				if vertex.cmp(&other_sorted_vertices[i]) != Ordering::Equal {
					return vertex.cmp(&other_sorted_vertices[i]);
				}
			}
			Ordering::Equal
		}
	}
}

impl PartialOrd for Polygon {
	fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
		Some(self.cmp(other))
	}
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

#[test]
fn polygons_equal() {
	let a = Polygon {
		vertices: vec![
			Vertex { x: 16.0, y: 32.0 },
			Vertex { x: 0.0, y: 0.0 },
			Vertex { x: 128.0, y: 0.0 },
			Vertex { x: 128.0, y: 16.0 },
			Vertex { x: 16.0, y: 16.0 },
			Vertex { x: 16.0, y: 32.0 },
		],
	};
	let b = Polygon {
		vertices: vec![
			Vertex { x: 0.0, y: 0.0 },
			Vertex { x: 128.0, y: 0.0 },
			Vertex { x: 128.0, y: 16.0 },
			Vertex { x: 16.0, y: 16.0 },
			Vertex { x: 16.0, y: 32.0 },
			Vertex { x: 0.0, y: 0.0 },
		],
	};
	assert_eq!(a, b);
}
