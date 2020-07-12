pub mod builder;
pub mod collision;
pub mod navigation;

pub struct Mesh {
	pub collision: collision::CollisionMesh,
	pub navigation: navigation::NavigationMesh,
}
