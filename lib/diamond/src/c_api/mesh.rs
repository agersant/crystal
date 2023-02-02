use crate::c_api::geometry::*;
use crate::mesh::Mesh;
use geo_types::*;
use std::iter::FromIterator;

#[no_mangle]
pub unsafe extern "C" fn mesh_new() -> *mut Mesh {
    let mesh = Mesh::default();
    Box::into_raw(Box::new(mesh))
}

#[no_mangle]
pub unsafe extern "C" fn mesh_delete(mesh: *mut Mesh) {
    if mesh.is_null() {
        return;
    }
    let boxed_mesh = Box::from_raw(mesh);
    drop(boxed_mesh);
}

#[no_mangle]
pub unsafe extern "C" fn mesh_list_collision_polygons(
    mesh: *mut Mesh,
    out_polygons: *mut CPolygons,
) {
    if mesh.is_null() {
        return;
    }
    let mesh = &*mesh;
    let contours = mesh.collision.get_contours();
    *out_polygons = CPolygons::from_iter(contours.iter());
}

#[no_mangle]
pub unsafe extern "C" fn mesh_list_navigation_polygons(
    mesh: *mut Mesh,
    out_polygons: *mut CPolygons,
) {
    if mesh.is_null() {
        return;
    }
    let mesh = &*mesh;
    let triangles = mesh.navigation.get_triangles();
    *out_polygons = CPolygons::from_iter(triangles.iter());
}

#[no_mangle]
pub unsafe extern "C" fn mesh_plan_path(
    mesh: *mut Mesh,
    start_x: f32,
    start_y: f32,
    end_x: f32,
    end_y: f32,
    out_path: *mut CPolygon,
) -> bool {
    if mesh.is_null() {
        return false;
    }
    let mesh = &*mesh;
    let start = Point::new(start_x, start_y);
    let end = Point::new(end_x, end_y);
    if let Some(path) = mesh.navigation.compute_path(&start, &end) {
        *out_path = (&path).into();
        true
    } else {
        false
    }
}

#[no_mangle]
pub unsafe extern "C" fn mesh_get_nearest_navigable_point(
    mesh: *mut Mesh,
    x: f32,
    y: f32,
) -> CVertex {
    if mesh.is_null() {
        return CVertex::default();
    }
    let mesh = &*mesh;
    mesh.navigation
        .get_nearest_navigable_point(&Point::new(x, y))
        .unwrap_or_else(|| Point::new(x, y))
        .into()
}
