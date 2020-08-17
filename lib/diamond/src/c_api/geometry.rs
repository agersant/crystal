use geo_types::*;
use std::borrow::Borrow;
use std::iter::FromIterator;
use std::mem;
use std::slice;

#[repr(C)]
#[derive(Debug, Default)]
pub struct CVertex {
	pub x: f32,
	pub y: f32,
}

impl<P: Borrow<Point<f32>>> From<P> for CVertex {
	fn from(point: P) -> CVertex {
		CVertex {
			x: point.borrow().x(),
			y: point.borrow().y(),
		}
	}
}

impl From<&CVertex> for Point<f32> {
	fn from(vertex: &CVertex) -> Point<f32> {
		Point::new(vertex.x, vertex.y)
	}
}

// Polygon

#[repr(C)]
#[derive(Debug)]
pub struct CPolygon {
	pub vertices: *mut CVertex,
	pub num_vertices: i32,
}

impl From<&LineString<f32>> for CPolygon {
	fn from(t: &LineString<f32>) -> CPolygon {
		let mut c_vertices: Vec<CVertex> = t.points_iter().map(|vertex| (&vertex).into()).collect();
		let ptr = c_vertices.as_mut_ptr();
		let len = c_vertices.len();
		mem::forget(c_vertices);
		CPolygon {
			vertices: ptr,
			num_vertices: len as i32,
		}
	}
}

impl From<&Triangle<f32>> for CPolygon {
	fn from(t: &Triangle<f32>) -> CPolygon {
		t.to_polygon().exterior().into()
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
	let c_polygon = &*c_polygon;
	drop(c_polygon);
}

// Polygons

#[repr(C)]
#[derive(Debug)]
pub struct CPolygons {
	pub polygons: *mut CPolygon,
	pub num_polygons: i32,
}

impl<T> FromIterator<T> for CPolygons
where
	T: Into<CPolygon>,
{
	fn from_iter<I: IntoIterator<Item = T>>(iter: I) -> Self {
		let mut c_polygons: Vec<CPolygon> = iter.into_iter().map(|s| s.into()).collect();
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
