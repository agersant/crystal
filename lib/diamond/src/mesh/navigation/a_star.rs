use crate::geometry::LineExt;
use crate::mesh::navigation::*;
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

pub fn compute_triangle_path<'a>(
	mesh: &'a NavigationMesh,
	from: FaceHandle<'a, Vertex, CdtEdge>,
	to: FaceHandle<'a, Vertex, CdtEdge>,
	exact_destination: &Point<f32>,
) -> Option<Vec<FaceHandle<'a, Vertex, CdtEdge>>> {
	let path = astar(
		&from.fix(),
		|&face| {
			let face = mesh.triangulation.face(face);
			face.adjacent_edges()
				.filter(|e| mesh.is_face_navigable(&e.sym().face()))
				.map(move |e| {
					let neighbour = e.sym().face();
					let cost = movement_cost(&face, &neighbour);
					(neighbour.fix(), cost.ceil() as i32)
				})
		},
		|&face| {
			let face = mesh.triangulation.face(face);
			heuristic(&face, exact_destination).ceil() as i32
		},
		|&face| face == to.fix(),
	);

	path.map(|(fixed_handles, _)| {
		fixed_handles
			.into_iter()
			.map(|f| mesh.triangulation.face(f))
			.collect()
	})
}
