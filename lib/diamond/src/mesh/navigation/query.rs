use crate::geometry::*;
use crate::mesh::navigation::*;
use ordered_float::OrderedFloat;
use pathfinding::prelude::*;

fn heuristic(from: &FaceHandle<Vertex, CdtEdge>, to: &Point<f32>) -> f32 {
	let line = Line::new(from.center(), to.clone());
	line.length()
}

fn movement_cost(from: &FaceHandle<Vertex, CdtEdge>, to: &FaceHandle<Vertex, CdtEdge>) -> f32 {
	let line = Line::new(from.center(), to.center());
	line.length()
}

// Based on:
// http://digestingduck.blogspot.com/2010/03/simple-stupid-funnel-algorithm.html
fn funnel(
	mesh: &NavigationMesh,
	from: &Point<f32>,
	to: &Point<f32>,
	triangle_path: Vec<FixedFaceHandle>,
) -> Vec<Point<f32>> {
	let mut path = Vec::new();
	path.push(*from);
	for face in triangle_path {
		let face = mesh.triangulation.face(face);
		path.push(face.center());
	}
	path.push(*to);
	path
}

pub fn compute_path<'a>(
	mesh: &'a NavigationMesh,
	from_point: &Point<f32>,
	to_point: &Point<f32>,
	from_face: FaceHandle<'a, Vertex, CdtEdge>,
	to_face: FaceHandle<'a, Vertex, CdtEdge>,
) -> Option<Vec<Point<f32>>> {
	astar(
		&from_face.fix(),
		|&face| {
			let face = mesh.triangulation.face(face);
			face.adjacent_edges()
				.filter(|e| mesh.is_face_navigable(&e.sym().face()))
				.map(move |e| {
					let neighbour = e.sym().face();
					let cost = movement_cost(&face, &neighbour);
					(neighbour.fix(), OrderedFloat(cost))
				})
		},
		|&face| {
			let face = mesh.triangulation.face(face);
			OrderedFloat(heuristic(&face, to_point))
		},
		|&face| face == to_face.fix(),
	)
	.map(|(path, _length)| funnel(mesh, from_point, to_point, path))
}
