use crate::c_api::geometry::*;
use crate::mesh::builder::MeshBuilder;
use crate::mesh::Mesh;
use geo_types::*;
use std::slice;

#[no_mangle]
pub unsafe extern "C" fn mesh_builder_new(
    num_tiles_x: u32,
    num_tiles_y: u32,
    tile_width: u32,
    tile_height: u32,
    navigation_padding: f32,
) -> *mut MeshBuilder {
    let builder = MeshBuilder::new(
        num_tiles_x,
        num_tiles_y,
        tile_width,
        tile_height,
        navigation_padding,
    );
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
    let line_string = c_vertices
        .iter()
        .map(|v| v.into())
        .collect::<Vec<Point<f32>>>()
        .into();
    (*builder).add_polygon(tile_x, tile_y, line_string);
}

#[no_mangle]
pub unsafe extern "C" fn mesh_builder_build_mesh(builder: *mut MeshBuilder, out_mesh: *mut Mesh) {
    if builder.is_null() {
        return;
    }
    let mesh = (*builder).build();
    *out_mesh = mesh;
}
