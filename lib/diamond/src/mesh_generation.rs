use crate::types::*;

pub fn generate_mesh(polygons: &[Polygon]) -> CollisionMesh {
	CollisionMesh { chains: Vec::new() }
}
