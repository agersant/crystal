use crate::c_api::geometry::*;
use crate::mesh::collision;
use std::mem;

impl From<collision::Mesh> for CPolygons {
	fn from(mut mesh: collision::Mesh) -> CPolygons {
		let polygons = mem::replace(&mut mesh.polygons, Vec::new());
		let mut c_polygons: Vec<CPolygon> =
			polygons.into_iter().map(|polygon| polygon.into()).collect();
		let ptr = c_polygons.as_mut_ptr();
		let len = c_polygons.len();
		mem::forget(c_polygons);
		CPolygons {
			polygons: ptr,
			num_polygons: len as i32,
		}
	}
}
