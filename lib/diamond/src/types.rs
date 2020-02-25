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
pub struct Vertices(pub Vec<Vertex>);

#[derive(Clone, Debug, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub struct Polygon(pub Vertices);

#[derive(Clone, Debug, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub struct Chain(pub Vertices);

impl PartialEq for Vertices {
	fn eq(&self, other: &Self) -> bool {
		if self.0.len() != other.0.len() {
			return false;
		}
		let self_vertices: HashSet<Vertex> = self.0.iter().cloned().collect();
		let other_vertices: HashSet<Vertex> = other.0.iter().cloned().collect();
		self_vertices == other_vertices
	}
}

impl Eq for Vertices {}

impl Hash for Vertices {
	fn hash<H: Hasher>(&self, state: &mut H) {
		if self.0.len() > 0 {
			assert!(self.0.len() > 1);
			assert_eq!(self.0.first(), self.0.last());
		}
		let mut sorted_vertices: Vec<&Vertex> = self.0.iter().take(self.0.len() - 1).collect();
		sorted_vertices.sort();
		sorted_vertices.hash(state);
	}
}

impl Ord for Vertices {
	fn cmp(&self, other: &Self) -> Ordering {
		if self.0.len() < other.0.len() {
			Ordering::Less
		} else if self.0.len() > other.0.len() {
			Ordering::Greater
		} else {
			let mut self_sorted_vertices = self.0.clone();
			let mut other_sorted_vertices = other.0.clone();
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

impl PartialOrd for Vertices {
	fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
		Some(self.cmp(other))
	}
}

#[derive(Debug)]
pub struct CollisionMesh {
	pub chains: Vec<Chain>,
}

impl PartialEq for CollisionMesh {
	fn eq(&self, other: &Self) -> bool {
		if self.chains.len() != other.chains.len() {
			return false;
		}
		let self_chains: HashSet<Chain> = self.chains.iter().cloned().collect();
		let other_chains: HashSet<Chain> = other.chains.iter().cloned().collect();
		self_chains == other_chains
	}
}

impl From<geo_types::MultiPolygon<f32>> for CollisionMesh {
	fn from(multi_polygon: geo_types::MultiPolygon<f32>) -> CollisionMesh {
		let mut chains: Vec<Chain> = Vec::new();
		for polygon in multi_polygon.into_iter() {
			chains.push(Chain(Vertices(
				polygon
					.exterior()
					.points_iter()
					.into_iter()
					.map(|p| Vertex { x: p.x(), y: p.y() })
					.collect::<Vec<Vertex>>(),
			)));
			for interior in polygon.interiors().iter() {
				chains.push(Chain(Vertices(
					interior
						.points_iter()
						.into_iter()
						.map(|p| Vertex { x: p.x(), y: p.y() })
						.collect::<Vec<Vertex>>(),
				)));
			}
		}
		CollisionMesh { chains }
	}
}

impl CollisionMesh {
	pub fn bounding_box(&self) -> (Vertex, Vertex) {
		let mut top_left = Vertex {
			x: std::f32::INFINITY,
			y: std::f32::INFINITY,
		};

		let mut bottom_right = Vertex {
			x: std::f32::NEG_INFINITY,
			y: std::f32::NEG_INFINITY,
		};

		for chain in self.chains.iter() {
			for vertex in (chain.0).0.iter() {
				top_left.x = vertex.x.min(top_left.x);
				top_left.y = vertex.y.min(top_left.y);
				bottom_right.x = vertex.x.max(bottom_right.x);
				bottom_right.y = vertex.y.max(bottom_right.y);
			}
		}

		(top_left, bottom_right)
	}
}

#[test]
fn chains_equal() {
	let a = Chain(Vertices(vec![
		Vertex { x: 16.0, y: 32.0 },
		Vertex { x: 0.0, y: 0.0 },
		Vertex { x: 128.0, y: 0.0 },
		Vertex { x: 128.0, y: 16.0 },
		Vertex { x: 16.0, y: 16.0 },
		Vertex { x: 16.0, y: 32.0 },
	]));
	let b = Chain(Vertices(vec![
		Vertex { x: 0.0, y: 0.0 },
		Vertex { x: 128.0, y: 0.0 },
		Vertex { x: 128.0, y: 16.0 },
		Vertex { x: 16.0, y: 16.0 },
		Vertex { x: 16.0, y: 32.0 },
		Vertex { x: 0.0, y: 0.0 },
	]));
	assert_eq!(a, b);
}

#[test]
fn meshes_equal() {
	let a = CollisionMesh {
		chains: vec![
			Chain(Vertices(vec![
				Vertex { x: 16.0, y: 32.0 },
				Vertex { x: 0.0, y: 0.0 },
				Vertex { x: 128.0, y: 0.0 },
				Vertex { x: 128.0, y: 16.0 },
				Vertex { x: 16.0, y: 16.0 },
				Vertex { x: 16.0, y: 32.0 },
			])),
			Chain(Vertices(vec![
				Vertex { x: 10.0, y: 10.0 },
				Vertex { x: 20.0, y: 20.0 },
				Vertex { x: 10.0, y: 20.0 },
				Vertex { x: 10.0, y: 10.0 },
			])),
		],
	};
	let b = CollisionMesh {
		chains: vec![
			Chain(Vertices(vec![
				Vertex { x: 20.0, y: 20.0 },
				Vertex { x: 10.0, y: 20.0 },
				Vertex { x: 10.0, y: 10.0 },
				Vertex { x: 20.0, y: 20.0 },
			])),
			Chain(Vertices(vec![
				Vertex { x: 0.0, y: 0.0 },
				Vertex { x: 128.0, y: 0.0 },
				Vertex { x: 128.0, y: 16.0 },
				Vertex { x: 16.0, y: 16.0 },
				Vertex { x: 16.0, y: 32.0 },
				Vertex { x: 0.0, y: 0.0 },
			])),
		],
	};
	assert_eq!(a, b);
}
