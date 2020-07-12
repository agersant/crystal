pub mod builder;
pub mod collision;
pub mod navigation;

pub struct Mesh {
	pub collision: collision::Mesh,
	pub navigation: navigation::Mesh,
}
