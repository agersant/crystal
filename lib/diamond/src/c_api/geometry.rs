use crate::geometry::*;
use std::mem;
use std::slice;

#[repr(C)]
#[derive(Debug)]
pub struct CVertex {
	pub x: f32,
	pub y: f32,
}

impl Default for CVertex {
	fn default() -> CVertex {
		CVertex { x: 0., y: 0. }
	}
}

impl From<&Vertex> for CVertex {
	fn from(vertex: &Vertex) -> CVertex {
		CVertex {
			x: vertex.x,
			y: vertex.y,
		}
	}
}

impl From<&CVertex> for Vertex {
	fn from(vertex: &CVertex) -> Vertex {
		Vertex {
			x: vertex.x,
			y: vertex.y,
		}
	}
}

// Polygon

#[repr(C)]
#[derive(Debug)]
pub struct CPolygon {
	pub vertices: *mut CVertex,
	pub num_vertices: i32,
}

impl From<&Polygon> for CPolygon {
	fn from(polygon: &Polygon) -> CPolygon {
		let mut c_vertices: Vec<CVertex> = polygon
			.vertices
			.iter()
			.map(|vertex| vertex.into())
			.collect();
		let ptr = c_vertices.as_mut_ptr();
		let len = c_vertices.len();
		mem::forget(c_vertices);
		CPolygon {
			vertices: ptr,
			num_vertices: len as i32,
		}
	}
}

impl Drop for CPolygon {
	fn drop(&mut self) {
		if !self.vertices.is_null() && self.num_vertices > 0 {
			let c_vertices: &[CVertex] =
				unsafe { slice::from_raw_parts(self.vertices, self.num_vertices as usize) };
			drop(c_vertices);
		}
	}
}

#[no_mangle]
pub unsafe extern "C" fn polygon_delete(c_polygon: *mut CPolygon) {
	if c_polygon.is_null() {
		return;
	}
	let boxed_polygon = Box::from_raw(c_polygon);
	drop(boxed_polygon);
}

// Polygons

#[repr(C)]
#[derive(Debug)]
pub struct CPolygons {
	pub polygons: *mut CPolygon,
	pub num_polygons: i32,
}

impl From<&Vec<Polygon>> for CPolygons {
	fn from(polygons: &Vec<Polygon>) -> CPolygons {
		let mut c_polygons: Vec<CPolygon> = polygons.iter().map(|polygon| polygon.into()).collect();
		let ptr = c_polygons.as_mut_ptr();
		let len = c_polygons.len();
		mem::forget(c_polygons);
		CPolygons {
			polygons: ptr,
			num_polygons: len as i32,
		}
	}
}

#[no_mangle]
pub unsafe extern "C" fn polygons_delete(c_polygons: *mut CPolygons) {
	if c_polygons.is_null() {
		return;
	}
	let c_polygons = &*c_polygons;
	if !c_polygons.polygons.is_null() && c_polygons.num_polygons > 0 {
		let polygons: &mut [CPolygon] =
			slice::from_raw_parts_mut(c_polygons.polygons, c_polygons.num_polygons as usize);
		drop(polygons);
	}
}
