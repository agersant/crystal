use crate::c_api::geometry::*;
use crate::mesh::Mesh;

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
	*out_polygons = (&mesh.collision.polygons).into();
}

#[no_mangle]
pub unsafe extern "C" fn mesh_plan_path(
	mesh: *mut Mesh,
	_start_x: f32,
	_start_y: f32,
	_end_x: f32,
	_end_y: f32,
	_out_path: *mut CPolygon,
) {
	if mesh.is_null() {
		return;
	}
	let _mesh = &*mesh;
	// TODO
}

#[no_mangle]
pub unsafe extern "C" fn mesh_get_nearest_navigable_point(
	mesh: *mut Mesh,
	_x: f32,
	_y: f32,
) -> CVertex {
	if mesh.is_null() {
		return CVertex::default();
	}
	let _mesh = &*mesh;
	// TODO
	CVertex::default()
}
