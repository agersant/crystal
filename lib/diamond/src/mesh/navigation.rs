use crate::mesh::collision::CollisionMesh;

pub struct NavigationMesh {}

impl NavigationMesh {
	pub fn build(_collision_mesh: &CollisionMesh) -> NavigationMesh {
		NavigationMesh::default()
	}
}

impl Default for NavigationMesh {
	fn default() -> Self {
		NavigationMesh {}
	}
}
