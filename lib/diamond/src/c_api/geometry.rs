use crate::geometry::*;
use std::mem;
use std::ptr::*;
use std::slice;

#[repr(C)]
#[derive(Debug)]
pub struct CVertex {
	pub x: f32,
	pub y: f32,
}

#[repr(C)]
#[derive(Debug)]
pub struct CPolygon {
	pub vertices: *mut CVertex,
	pub num_vertices: i32,
}

#[repr(C)]
#[derive(Debug)]
pub struct CPolygons {
	pub polygons: *mut CPolygon,
	pub num_polygons: i32,
}

impl Default for CPolygons {
	fn default() -> CPolygons {
		CPolygons {
			polygons: null_mut(),
			num_polygons: 0,
		}
	}
}

impl From<Vertex> for CVertex {
	fn from(vertex: Vertex) -> CVertex {
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

impl From<Polygon> for CPolygon {
	fn from(mut polygon: Polygon) -> CPolygon {
		let vertices = mem::replace(&mut polygon.vertices, Vec::new());
		let mut c_vertices: Vec<CVertex> =
			vertices.into_iter().map(|vertex| vertex.into()).collect();
		let ptr = c_vertices.as_mut_ptr();
		let len = c_vertices.len();
		mem::forget(c_vertices);
		CPolygon {
			vertices: ptr,
			num_vertices: len as i32,
		}
	}
}

impl Drop for CPolygons {
	fn drop(&mut self) {
		if !self.polygons.is_null() && self.num_polygons > 0 {
			let c_polygons: &mut [CPolygon] =
				unsafe { slice::from_raw_parts_mut(self.polygons, self.num_polygons as usize) };
			for c_polygon in c_polygons.iter_mut() {
				if !c_polygon.vertices.is_null() && c_polygon.num_vertices > 0 {
					let c_vertices: &[CVertex] = unsafe {
						slice::from_raw_parts(c_polygon.vertices, c_polygon.num_vertices as usize)
					};
					drop(c_vertices);
				}
			}
			drop(c_polygons);
		}
	}
}
