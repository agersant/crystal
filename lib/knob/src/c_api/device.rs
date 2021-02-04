use crate::device::Device;

#[no_mangle]
pub unsafe extern "C" fn device_new() -> *mut Device {
	let device = Device::new();
	Box::into_raw(Box::new(device))
}

#[no_mangle]
pub unsafe extern "C" fn device_delete(device: *mut Device) {
	if device.is_null() {
		return;
	}
	let boxed_device = Box::from_raw(device);
	drop(boxed_device);
}
