use crate::mesh::collision::CollisionMesh;
use crate::mesh::navigation::NavigationMesh;

pub mod builder;
pub mod collision;
pub mod navigation;

pub struct Mesh {
	pub collision: CollisionMesh,
	pub navigation: NavigationMesh,
}

impl Default for Mesh {
	fn default() -> Self {
		Mesh {
			collision: CollisionMesh::default(),
			navigation: NavigationMesh::default(),
		}
	}
}
