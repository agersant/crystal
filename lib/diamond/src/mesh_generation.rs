use crate::types::*;
use geo::algorithm::simplify::Simplify;
use geo_booleanop::boolean::BooleanOp;

#[derive(Debug)]
pub struct CollisionMeshBuilder {
	polygons: Vec<Polygon>,
}

impl CollisionMeshBuilder {
	pub fn new() -> CollisionMeshBuilder {
		CollisionMeshBuilder {
			polygons: Vec::new(),
		}
	}

	pub fn add_polygon(&mut self, polygon: Polygon) {
		self.polygons.push(polygon);
	}

	pub fn build(&self) -> CollisionMesh {
		let mut union_result: geo_types::MultiPolygon<f32> =
			Vec::<geo_types::Polygon<f32>>::new().into();

		for p in self.polygons.iter() {
			let polygon = geo_types::Polygon::<f32>::new(
				geo_types::LineString::from(
					(p.0)
						.0
						.iter()
						.map(|v| (v.x as f32, v.y as f32))
						.collect::<Vec<(f32, f32)>>(),
				),
				vec![],
			);
			union_result = union_result.union(&polygon);
		}
		union_result = union_result.simplify(&0.1);

		union_result.into()
	}
}
