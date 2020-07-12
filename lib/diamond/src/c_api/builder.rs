use crate::c_api::geometry::*;
use crate::geometry::*;
use crate::mesh::builder::MeshBuilder;
use crate::mesh::Mesh;
use std::slice;

#[no_mangle]
pub unsafe extern "C" fn mesh_builder_new(num_tiles_x: i32, num_tiles_y: i32) -> *mut MeshBuilder {
	let builder = MeshBuilder::new(num_tiles_x, num_tiles_y);
	Box::into_raw(Box::new(builder))
}

#[no_mangle]
pub unsafe extern "C" fn mesh_builder_delete(builder: *mut MeshBuilder) {
	if builder.is_null() {
		return;
	}
	let boxed_builder = Box::from_raw(builder);
	drop(boxed_builder);
}

#[no_mangle]
pub unsafe extern "C" fn mesh_builder_add_polygon(
	builder: *mut MeshBuilder,
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
pub unsafe extern "C" fn mesh_builder_build_mesh(builder: *mut MeshBuilder, out_mesh: *mut Mesh) {
	if builder.is_null() {
		return;
	}
	let mesh = (&*builder).build();
	*out_mesh = mesh;
}
