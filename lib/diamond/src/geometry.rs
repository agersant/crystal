#[derive(Clone, Debug)]
pub struct Vertex {
	pub x: f32,
	pub y: f32,
}

#[derive(Clone, Debug)]
pub struct Polygon {
	pub vertices: Vec<Vertex>,
}

impl From<&Polygon> for geo_types::Polygon<f32> {
	fn from(polygon: &Polygon) -> geo_types::Polygon<f32> {
		geo_types::Polygon::<f32>::new(
			geo_types::LineString::from(
				polygon
					.vertices
					.iter()
					.map(|v| (v.x as f32, v.y as f32))
					.collect::<Vec<(f32, f32)>>(),
			),
			vec![],
		)
	}
}
