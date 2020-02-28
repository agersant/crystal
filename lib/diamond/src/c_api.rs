use std::mem;
use std::ptr::*;
use std::slice;

use crate::mesh_generation::*;
use crate::types::*;

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
pub struct CCollisionMesh {
	pub polygons: *mut CPolygon,
	pub num_polygons: i32,
}

impl Default for CCollisionMesh {
	fn default() -> CCollisionMesh {
		CCollisionMesh {
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

impl From<CollisionMesh> for CCollisionMesh {
	fn from(mut mesh: CollisionMesh) -> CCollisionMesh {
		let polygons = mem::replace(&mut mesh.polygons, Vec::new());
		let mut c_polygons: Vec<CPolygon> =
			polygons.into_iter().map(|polygon| polygon.into()).collect();
		let ptr = c_polygons.as_mut_ptr();
		let len = c_polygons.len();
		mem::forget(c_polygons);
		CCollisionMesh {
			polygons: ptr,
			num_polygons: len as i32,
		}
	}
}

impl Drop for CCollisionMesh {
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

#[no_mangle]
pub unsafe extern "C" fn mesh_builder_new(
	num_tiles_x: i32,
	num_tiles_y: i32,
) -> *mut CollisionMeshBuilder {
	let builder = CollisionMeshBuilder::new(num_tiles_x, num_tiles_y);
	Box::into_raw(Box::new(builder))
}

#[no_mangle]
pub unsafe extern "C" fn mesh_builder_add_polygon(
	builder: *mut CollisionMeshBuilder,
	tile_x: i32,
	tile_y: i32,
	vertices: *const CVertex,
	num_vertices: i32,
) {
	if builder.is_null() || vertices.is_null() || num_vertices < 3 {
		return;
	}
	let c_vertices: &[CVertex] = slice::from_raw_parts(vertices, num_vertices as usize);
	let vertices: Vec<Vertex> = c_vertices.iter().map(|v| v.into()).collect();
	let polygon = Polygon { vertices };
	(&mut *builder).add_polygon(tile_x, tile_y, polygon);
}

#[no_mangle]
pub unsafe extern "C" fn mesh_builder_build_mesh(
	builder: *mut CollisionMeshBuilder,
) -> *mut CCollisionMesh {
	if builder.is_null() {
		return null_mut();
	}
	let mesh = (&*builder).build();
	Box::into_raw(Box::new(mesh.into()))
}

#[no_mangle]
pub unsafe extern "C" fn mesh_builder_delete(builder: *mut CollisionMeshBuilder) {
	if builder.is_null() {
		return;
	}
	let boxed_builder = Box::from_raw(builder);
	drop(boxed_builder);
}

#[no_mangle]
pub unsafe extern "C" fn mesh_delete(mesh: *mut CCollisionMesh) {
	if mesh.is_null() {
		return;
	}
	let boxed_mesh = Box::from_raw(mesh);
	drop(boxed_mesh);
}

#[test]
fn c_conversions() {
	let mesh = CollisionMesh {
		polygons: vec![
			Polygon {
				vertices: vec![
					Vertex { x: 0.0, y: 10.0 },
					Vertex { x: 5.0, y: 15.0 },
					Vertex { x: 8.0, y: 10.0 },
				],
			},
			Polygon {
				vertices: vec![
					Vertex { x: 0.0, y: 10.0 },
					Vertex { x: 5.0, y: 15.0 },
					Vertex { x: 8.0, y: 10.0 },
				],
			},
			Polygon {
				vertices: vec![
					Vertex { x: 0.0, y: 10.0 },
					Vertex { x: 5.0, y: 15.0 },
					Vertex { x: 8.0, y: 10.0 },
				],
			},
		],
	};
	let c_mesh: CCollisionMesh = mesh.into();
	drop(c_mesh);
}
