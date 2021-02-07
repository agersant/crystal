use std::ffi::CString;
use std::os::raw::{c_char, c_int};
use std::{mem, ptr};

use crate::io;

#[no_mangle]
pub unsafe extern "C" fn list_devices(out_num_devices: *mut c_int) -> *mut *mut c_char {
	let mut devices = io::list_devices()
		.into_iter()
		.map(|d| CString::new(d).unwrap_or_default().into_raw())
		.collect::<Vec<_>>();
	devices.shrink_to_fit();
	let num_devices = devices.len();
	let devices_ptr = devices.as_mut_ptr();
	mem::forget(devices);
	ptr::write(out_num_devices, num_devices as c_int);
	devices_ptr
}

#[no_mangle]
unsafe extern "C" fn free_device_list(device_list: *mut *mut c_char, num_devices: c_int) {
	let num_devices = num_devices as usize;
	let device_list = Vec::from_raw_parts(device_list, num_devices, num_devices);
	for device in device_list {
		let device_name = CString::from_raw(device);
		mem::drop(device_name);
	}
}

#[no_mangle]
pub unsafe extern "C" fn connect() {
	io::connect();
}

#[no_mangle]
pub unsafe extern "C" fn get_port_number() -> usize {
	io::get_port_number()
}

#[no_mangle]
pub unsafe extern "C" fn set_port_number(port_number: usize) {
	io::set_port_number(port_number);
}

#[no_mangle]
pub unsafe extern "C" fn set_mode(mode: io::Mode) {
	io::set_mode(mode);
}

#[no_mangle]
pub unsafe extern "C" fn read_knob(cc_index: u8) -> f32 {
	io::read_knob(cc_index)
}

#[no_mangle]
pub unsafe extern "C" fn write_knob(cc_index: u8, value: f32) {
	io::write_knob(cc_index, value)
}

#[no_mangle]
pub unsafe extern "C" fn disconnect() {
	io::disconnect();
}

#[test]
fn omnibus() {
	unsafe {
		get_port_number();
		set_port_number(0);
		set_mode(io::Mode::Absolute);
		connect();
		write_knob(70, 1.0);
		read_knob(70);
		disconnect();
	}
}

#[test]
fn list_and_free_devices() {
	unsafe {
		let mut num_devices: c_int = -1;
		let devices = list_devices(&mut num_devices);
		assert!(num_devices >= 0);
		free_device_list(devices, num_devices);
	}
}
