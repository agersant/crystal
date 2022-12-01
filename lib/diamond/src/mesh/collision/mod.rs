pub use self::builder::CollisionMeshBuilder;
use geo::prelude::*;
use geo_booleanop::boolean::BooleanOp;
use geo_types::*;

mod builder;
#[cfg(test)]
mod tests;

#[derive(Debug)]
pub struct CollisionMesh {
	pub obstacles: MultiPolygon<f32>,
}

impl Default for CollisionMesh {
	fn default() -> Self {
		let polygons: Vec<Polygon<f32>> = Vec::new();
		CollisionMesh {
			obstacles: polygons.into(),
		}
	}
}

impl PartialEq for CollisionMesh {
	fn eq(&self, other: &Self) -> bool {
		let xor = self.obstacles.xor(&other.obstacles);
		xor.bounding_rect().is_none()
	}
}

impl CollisionMesh {
	pub fn builder(num_tiles_x: usize, num_tiles_y: usize) -> CollisionMeshBuilder {
		CollisionMeshBuilder::new(num_tiles_x, num_tiles_y)
	}

	pub fn get_contours(&self) -> Vec<LineString<f32>> {
		let mut polygons: Vec<LineString<f32>> = Vec::new();
		for polygon in &self.obstacles.0 {
			let exterior_vertices = polygon.exterior().clone().into_points();
			polygons.push(exterior_vertices.into());
			for interior in polygon.interiors() {
				let interior_vertices = interior.clone().into_points();
				polygons.push(interior_vertices.into());
			}
		}
		polygons
	}

	#[cfg(test)]
	pub fn bounding_box(&self) -> (Point<f32>, Point<f32>) {
		if self.obstacles.0.is_empty() {
			return (Point::new(0.0, 0.0), Point::new(0.0, 0.0));
		}
		let extremes = self.obstacles.extreme_points();
		(
			Point::new(extremes.xmin.x(), extremes.ymin.y()),
			Point::new(extremes.xmax.x(), extremes.ymax.y()),
		)
	}
}
