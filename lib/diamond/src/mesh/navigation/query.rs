use crate::geometry::LineExt;
use crate::mesh::navigation::*;
use ordered_float::OrderedFloat;
use pathfinding::prelude::*;

// TODO implement as FaceHandle extension?
fn face_center(face: &FaceHandle<Vertex, CdtEdge>) -> Point<f32> {
	let triangle = face.as_triangle();
	let x = (triangle[0][0] + triangle[1][0] + triangle[2][0]) / 3.0;
	let y = (triangle[0][1] + triangle[1][1] + triangle[2][1]) / 3.0;
	Point::new(x, y)
}

fn heuristic(from: &FaceHandle<Vertex, CdtEdge>, to: &Point<f32>) -> f32 {
	let line = Line::new(face_center(from), to.clone());
	line.length()
}

fn movement_cost(from: &FaceHandle<Vertex, CdtEdge>, to: &FaceHandle<Vertex, CdtEdge>) -> f32 {
	let line = Line::new(face_center(from), face_center(to));
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
		path.push(face_center(&face));
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
