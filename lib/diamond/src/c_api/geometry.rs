use geo_types::*;
use std::borrow::Borrow;
use std::iter::FromIterator;
use std::mem;
use std::slice;

#[repr(C)]
#[derive(Debug, Default, PartialEq)]
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

impl Default for CPolygon {
    fn default() -> Self {
        CPolygon {
            vertices: std::ptr::null_mut(),
            num_vertices: 0,
        }
    }
}

impl From<&LineString<f32>> for CPolygon {
    fn from(t: &LineString<f32>) -> CPolygon {
        let c_vertices: Vec<CVertex> = t.points_iter().map(|vertex| (&vertex).into()).collect();
        let len = c_vertices.len();
        let mut c_vertices = c_vertices.into_boxed_slice();
        let ptr = c_vertices.as_mut_ptr();
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
            unsafe {
                let length = self.num_vertices as usize;
                let ptr = slice::from_raw_parts_mut(self.vertices, self.num_vertices as usize)
                    .as_mut_ptr();
                let c_vertices = Vec::from_raw_parts(ptr, length, length);
                drop(c_vertices);
            }
        }
    }
}

#[no_mangle]
pub unsafe extern "C" fn polygon_new() -> *mut CPolygon {
    let c_polygon = CPolygon::default();
    Box::into_raw(Box::new(c_polygon))
}

#[no_mangle]
pub unsafe extern "C" fn polygon_delete(c_polygon: *mut CPolygon) {
    if c_polygon.is_null() {
        return;
    }
    let c_polygon = Box::from_raw(c_polygon);
    drop(c_polygon);
}

// Polygons

#[repr(C)]
#[derive(Debug)]
pub struct CPolygons {
    pub polygons: *mut CPolygon,
    pub num_polygons: i32,
}

impl Default for CPolygons {
    fn default() -> Self {
        CPolygons {
            polygons: std::ptr::null_mut(),
            num_polygons: 0,
        }
    }
}

impl<T> FromIterator<T> for CPolygons
where
    T: Into<CPolygon>,
{
    fn from_iter<I: IntoIterator<Item = T>>(iter: I) -> Self {
        let c_polygons: Vec<CPolygon> = iter.into_iter().map(|s| s.into()).collect();
        let len = c_polygons.len();
        let mut c_polygons = c_polygons.into_boxed_slice();
        let ptr = c_polygons.as_mut_ptr();
        mem::forget(c_polygons);
        CPolygons {
            polygons: ptr,
            num_polygons: len as i32,
        }
    }
}

impl Drop for CPolygons {
    fn drop(&mut self) {
        if !self.polygons.is_null() && self.num_polygons > 0 {
            unsafe {
                let length = self.num_polygons as usize;
                let ptr = slice::from_raw_parts_mut(self.polygons, self.num_polygons as usize)
                    .as_mut_ptr();
                let polygons = Vec::from_raw_parts(ptr, length, length);
                drop(polygons);
            }
        }
    }
}

#[no_mangle]
pub unsafe extern "C" fn polygons_new() -> *mut CPolygons {
    let c_polygons = CPolygons::default();
    Box::into_raw(Box::new(c_polygons))
}

#[no_mangle]
pub unsafe extern "C" fn polygons_delete(c_polygons: *mut CPolygons) {
    if c_polygons.is_null() {
        return;
    }
    let c_polygons = Box::from_raw(c_polygons);
    drop(c_polygons);
}
