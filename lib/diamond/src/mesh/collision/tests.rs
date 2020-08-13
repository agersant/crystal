use crate::mesh::collision::*;

#[test]
fn compare_meshes_equal_trivially_different() {
	let a = CollisionMesh {
		obstacles: vec![polygon![
			(x: 16.0, y: 32.0),
			(x: 0.0, y: 0.0),
			(x: 128.0, y: 0.0),
			(x: 128.0, y: 16.0),
			(x: 16.0, y: 16.0),
			(x: 16.0, y: 32.0),
		]]
		.into(),
	};

	let b = CollisionMesh {
		obstacles: vec![polygon![
			(x: 20.0, y: 20.0),
			(x: 10.0, y: 20.0),
			(x: 10.0, y: 10.0),
			(x: 20.0, y: 20.0),
		]]
		.into(),
	};

	assert_ne!(a, b);
}

#[test]
fn compare_meshes_different_but_overlapping() {
	let a = CollisionMesh {
		obstacles: vec![polygon![
			(x: 0.0, y: 0.0),
			(x: 10.0, y: 0.0),
			(x: 10.0, y: 10.0),
			(x: 0.0, y: 10.0),
			(x: 0.0, y: 0.0),
		]]
		.into(),
	};

	let b = CollisionMesh {
		obstacles: vec![polygon![
			(x: 0.0, y: 0.0),
			(x: 20.0, y: 0.0),
			(x: 20.0, y: 10.0),
			(x: 0.0, y: 10.0),
			(x: 0.0, y: 0.0),
		]]
		.into(),
	};

	assert_ne!(a, b);
}

#[test]
fn compare_meshes_cycled_vertices_and_polygons() {
	let a = CollisionMesh {
		obstacles: vec![
			polygon![
				(x: 16.0, y: 32.0),
				(x: 0.0, y: 0.0),
				(x: 128.0, y: 0.0),
				(x: 128.0, y: 16.0),
				(x: 16.0, y: 16.0),
				(x: 16.0, y: 32.0),
			],
			polygon![
				(x: 10.0, y: 10.0),
				(x: 20.0, y: 20.0),
				(x: 10.0, y: 20.0),
				(x: 10.0, y: 10.0),
			],
		]
		.into(),
	};

	let b = CollisionMesh {
		obstacles: vec![
			polygon![
				(x: 20.0, y: 20.0),
				(x: 10.0, y: 20.0),
				(x: 10.0, y: 10.0),
				(x: 20.0, y: 20.0),
			],
			polygon![
				(x: 0.0, y: 0.0),
				(x: 128.0, y: 0.0),
				(x: 128.0, y: 16.0),
				(x: 16.0, y: 16.0),
				(x: 16.0, y: 32.0),
				(x: 0.0, y: 0.0),
			],
		]
		.into(),
	};

	assert_eq!(a, b);
}
