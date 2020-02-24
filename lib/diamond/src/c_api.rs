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
pub struct CChain {
	pub vertices: *mut CVertex,
	pub num_vertices: i32,
}

#[repr(C)]
#[derive(Debug)]
pub struct CCollisionMesh {
	pub chains: *mut CChain,
	pub num_chains: i32,
}

impl Default for CCollisionMesh {
	fn default() -> CCollisionMesh {
		CCollisionMesh {
			chains: null_mut(),
			num_chains: 0,
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

impl From<Chain> for CChain {
	fn from(mut chain: Chain) -> CChain {
		let vertices = mem::replace(&mut chain.vertices, Vec::new());
		let mut c_vertices: Vec<CVertex> =
			vertices.into_iter().map(|vertex| vertex.into()).collect();
		let ptr = c_vertices.as_mut_ptr();
		let len = c_vertices.len();
		mem::forget(c_vertices);
		CChain {
			vertices: ptr,
			num_vertices: len as i32,
		}
	}
}

impl From<CollisionMesh> for CCollisionMesh {
	fn from(mut mesh: CollisionMesh) -> CCollisionMesh {
		let chains = mem::replace(&mut mesh.chains, Vec::new());
		let mut c_chains: Vec<CChain> = chains.into_iter().map(|chain| chain.into()).collect();
		let ptr = c_chains.as_mut_ptr();
		let len = c_chains.len();
		mem::forget(c_chains);
		CCollisionMesh {
			chains: ptr,
			num_chains: len as i32,
		}
	}
}

impl Drop for CCollisionMesh {
	fn drop(&mut self) {
		if !self.chains.is_null() && self.num_chains > 0 {
			dbg!(self.num_chains);
			let c_chains: &mut [CChain] =
				unsafe { slice::from_raw_parts_mut(self.chains, self.num_chains as usize) };
			for c_chain in c_chains.iter_mut() {
				if !c_chain.vertices.is_null() && c_chain.num_vertices > 0 {
					let c_vertices: &[CVertex] = unsafe {
						slice::from_raw_parts(c_chain.vertices, c_chain.num_vertices as usize)
					};
					drop(c_vertices);
				}
			}
			drop(c_chains);
		}
	}
}

#[no_mangle]
pub unsafe extern "C" fn newCollisionMesh(
	polygons_array: *const CPolygon,
	num_polygons: i32,
) -> *mut CCollisionMesh {
	if polygons_array.is_null() || num_polygons < 1 {
		return Box::into_raw(Box::new(CCollisionMesh::default()));
	}
	let c_polygons = slice::from_raw_parts(polygons_array, num_polygons as usize);

	let polygons = c_polygons
		.iter()
		.filter_map(|c_polygon| {
			if c_polygon.vertices.is_null() || c_polygon.num_vertices <= 2 {
				return None;
			}
			Some(Polygon {
				vertices: slice::from_raw_parts(
					c_polygon.vertices,
					c_polygon.num_vertices as usize,
				)
				.iter()
				.map(|v| v.into())
				.collect(),
			})
		})
		.collect::<Vec<Polygon>>();

	let mesh = generate_mesh(&polygons);

	let c_mesh = mesh.into();
	Box::into_raw(Box::new(c_mesh))
}

#[no_mangle]
pub unsafe extern "C" fn deleteCollisionMesh(mesh: *mut CCollisionMesh) {
	if mesh.is_null() {
		return;
	}
	let boxed_mesh = Box::from_raw(mesh);
	drop(boxed_mesh);
}

#[test]
fn c_conversions() {
	let mesh = CollisionMesh {
		chains: vec![
			Chain {
				vertices: vec![
					Vertex { x: 0.0, y: 10.0 },
					Vertex { x: 5.0, y: 15.0 },
					Vertex { x: 8.0, y: 10.0 },
				],
			},
			Chain {
				vertices: vec![
					Vertex { x: 0.0, y: 10.0 },
					Vertex { x: 5.0, y: 15.0 },
					Vertex { x: 8.0, y: 10.0 },
				],
			},
			Chain {
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
