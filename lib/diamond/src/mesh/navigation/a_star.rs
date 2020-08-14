use crate::geometry::LineExt;
use crate::mesh::navigation::*;
use std::cmp::Ordering;
use std::collections::{BinaryHeap, HashSet};

struct Node<'a> {
	cost: f32,
	heuristic: f32,
	path: Vec<FaceHandle<'a, Vertex, CdtEdge>>,
}

impl<'a> Node<'a> {
	pub fn face(&self) -> FaceHandle<'a, Vertex, CdtEdge> {
		self.path[self.path.len() - 1]
	}
}

impl PartialEq for Node<'_> {
	fn eq(&self, other: &Self) -> bool {
		self.cost + self.heuristic == other.cost + other.heuristic
	}
}
impl Eq for Node<'_> {}

impl Ord for Node<'_> {
	fn cmp(&self, other: &Self) -> Ordering {
		let self_score = self.cost + self.heuristic;
		let other_score = other.cost + other.heuristic;
		self_score
			.partial_cmp(&other_score)
			.unwrap_or(Ordering::Equal)
	}
}

impl<'a> PartialOrd for Node<'a> {
	fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
		Some(self.cmp(other))
	}
}

fn movement_cost(from: &FaceHandle<Vertex, CdtEdge>, to: &FaceHandle<Vertex, CdtEdge>) -> f32 {
	let line = Line::new(face_center(from), face_center(to));
	line.length_squared()
}

// TODO implement as FaceHandle extension?
fn face_center(face: &FaceHandle<Vertex, CdtEdge>) -> Point<f32> {
	let triangle = face.as_triangle();
	let x = (triangle[0][0] + triangle[1][0] + triangle[2][0]) / 3.0;
	let y = (triangle[0][1] + triangle[1][1] + triangle[2][1]) / 3.0;
	Point::new(x, y)
}

fn heuristic(from: &FaceHandle<Vertex, CdtEdge>, to: &Point<f32>) -> f32 {
	let line = Line::new(face_center(from), to.clone());
	line.length_squared()
}

pub fn compute_triangle_path<'a>(
	mesh: &NavigationMesh,
	from: FaceHandle<'a, Vertex, CdtEdge>,
	to: FaceHandle<'a, Vertex, CdtEdge>,
	exact_destination: &Point<f32>,
) -> Option<Vec<FaceHandle<'a, Vertex, CdtEdge>>> {
	let mut nodes_to_process = BinaryHeap::<Node>::new();
	let mut nodes_seen = HashSet::<FixedFaceHandle>::new();

	let starting_node = Node {
		cost: 0.0,
		heuristic: f32::INFINITY,
		path: vec![from],
	};
	nodes_to_process.push(starting_node);
	nodes_seen.insert(from.fix());

	while let Some(node) = nodes_to_process.pop() {
		if node.face().fix() == to.fix() {
			return Some(node.path);
		}
		for edge in node.face().adjacent_edges() {
			let neighbour = edge.sym().face();
			if nodes_seen.contains(&neighbour.fix()) {
				continue;
			}
			if !mesh.is_face_navigable(&neighbour) {
				continue;
			}
			let mut new_path = node.path.clone();
			new_path.push(neighbour);
			let new_node = Node {
				cost: movement_cost(&node.face(), &neighbour),
				heuristic: heuristic(&neighbour, exact_destination),
				path: new_path,
			};
			nodes_to_process.push(new_node);
			nodes_seen.insert(neighbour.fix());
		}
	}

	// TODO return best effort instead of none?
	None
}
