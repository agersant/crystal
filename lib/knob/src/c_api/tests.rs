use crate::c_api::device::*;

#[test]
fn device_lifecycle() {
	unsafe {
		let device = device_new();
		device_delete(device);
	}
}
