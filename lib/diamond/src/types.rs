#[derive(Debug)]
pub struct Vertex {
	pub x: f32,
	pub y: f32,
}

#[derive(Debug)]
pub struct Polygon {
	pub vertices: Vec<Vertex>,
}

#[derive(Debug)]
pub struct Chain {
	pub vertices: Vec<Vertex>,
}

#[derive(Debug)]
pub struct CollisionMesh {
	pub chains: Vec<Chain>,
}

impl From<geo_types::MultiPolygon<f32>> for CollisionMesh {
	fn from(multi_polygon: geo_types::MultiPolygon<f32>) -> CollisionMesh {
		let chains: Vec<Chain> = multi_polygon
			.into_iter()
			.map(|p| Chain {
				vertices: p
					.exterior()
					.points_iter()
					.into_iter()
					.map(|p| Vertex { x: p.x(), y: p.y() })
					.collect::<Vec<Vertex>>(),
			})
			.collect();
		CollisionMesh { chains }
	}
}
