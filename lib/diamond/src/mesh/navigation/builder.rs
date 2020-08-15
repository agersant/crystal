use crate::mesh::collision::*;
use crate::mesh::navigation::*;

#[derive(Debug)]
pub struct NavigationMeshBuilder {
	width: f32,
	height: f32,
	padding: f32,
}

impl NavigationMeshBuilder {
	pub fn new(width: f32, height: f32) -> Self {
		NavigationMeshBuilder {
			width,
			height,
			padding: 0.0,
		}
	}

	pub fn padding(mut self, padding: f32) -> Self {
		self.padding = padding.max(0.0);
		self
	}

	pub fn build(&self, collision_mesh: &CollisionMesh) -> NavigationMesh {
		type MP = geo_types::MultiPolygon<f32>;

		// Determine playable space
		let mut playable_space: MP = polygon![
			(x: self.padding, y: self.padding),
			(x: self.width - self.padding, y: self.padding),
			(x: self.width - self.padding, y: self.height - self.padding),
			(x: self.padding, y: self.height - self.padding)
		]
		.into();

		// TODO avoid cloning here
		for obstacle in collision_mesh.obstacles.clone() {
			let padded_obstacle = pad_obstacle(&obstacle, self.padding);
			playable_space = playable_space.difference(&padded_obstacle);
		}

		// Triangulate
		let mut triangulation = FloatCDT::with_tree_locate();
		// TODO avoid cloning here
		for polygon in playable_space.clone() {
			for line in polygon.exterior().lines() {
				let handle0 = triangulation.insert([line.start.x, line.start.y]);
				let handle1 = triangulation.insert([line.end.x, line.end.y]);
				if triangulation.can_add_constraint(handle0, handle1) {
					triangulation.add_constraint(handle0, handle1);
				}
			}
			for interior in polygon.interiors() {
				for line in interior.lines() {
					let handle0 = triangulation.insert([line.start.x, line.start.y]);
					let handle1 = triangulation.insert([line.end.x, line.end.y]);
					if triangulation.can_add_constraint(handle0, handle1) {
						triangulation.add_constraint(handle0, handle1);
					}
				}
			}
		}

		// Flag walkable triangles
		let mut navigable_faces = HashSet::new();
		for face in triangulation.triangles() {
			let triangle = face_to_geo_polygon(&face);
			let is_walkable = !collision_mesh
				.obstacles
				.clone()
				.into_iter()
				.any(|p| p.intersects(&triangle));
			if is_walkable {
				navigable_faces.insert(face.fix());
			}
		}

		NavigationMesh {
			triangulation,
			navigable_faces,
			playable_space: playable_space,
		}
	}
}
