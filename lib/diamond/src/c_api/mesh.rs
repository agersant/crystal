use crate::mesh::collision;
use crate::mesh::navigation;
use crate::mesh::Mesh;

#[repr(C)]
#[derive(Debug)]
pub struct CMesh {
	pub collision: *mut collision::Mesh,
	pub navigation: *mut navigation::Mesh,
}

impl From<Mesh> for CMesh {
	fn from(mesh: Mesh) -> CMesh {
		CMesh {
			collision: Box::into_raw(Box::new(mesh.collision)),
			navigation: Box::into_raw(Box::new(mesh.navigation)),
		}
	}
}

#[no_mangle]
pub unsafe extern "C" fn mesh_delete(mesh: *mut CMesh) {
	if mesh.is_null() {
		return;
	}
	let boxed_mesh = Box::from_raw(mesh);
	drop(boxed_mesh);
}
