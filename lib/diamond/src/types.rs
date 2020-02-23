use crate::c_api::Vertex;

pub struct Polygon {
	pub vertices: Vec<Vertex>,
}

pub struct Chain {
	pub vertices: Vec<Vertex>,
}

pub struct CollisionMesh {
	pub chains: Vec<Chain>,
}
