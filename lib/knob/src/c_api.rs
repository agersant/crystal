use std::ffi::CString;
use std::os::raw::{c_char, c_int};
use std::{mem, ptr};

use crate::io;

#[cfg(not(test))]
use crate::MIDI_HARDWARE_STATE as HARDWARE_STATE;

#[cfg(test)]
use crate::SAMPLE_HARDWARE_STATE as HARDWARE_STATE;

#[no_mangle]
pub unsafe extern "C" fn list_devices(out_num_devices: *mut c_int) -> *mut *mut c_char {
	let mut devices = io::list_devices(HARDWARE_STATE.clone())
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
pub unsafe extern "C" fn connect(port_number: usize) {
	io::connect(HARDWARE_STATE.clone(), port_number);
}

#[no_mangle]
pub unsafe extern "C" fn set_mode(mode: io::mode::Mode) {
	io::set_mode(HARDWARE_STATE.clone(), mode);
}

#[no_mangle]
pub unsafe extern "C" fn read_knob(cc_index: u8) -> f32 {
	io::read_knob(HARDWARE_STATE.clone(), cc_index)
}

#[no_mangle]
pub unsafe extern "C" fn write_knob(cc_index: u8, value: f32) {
	io::write_knob(HARDWARE_STATE.clone(), cc_index, value)
}

#[no_mangle]
pub unsafe extern "C" fn disconnect() {
	io::disconnect(HARDWARE_STATE.clone());
}

#[test]
fn omnibus() {
	unsafe {
		set_mode(io::mode::Mode::Absolute);
		connect(0);
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
		assert!(num_devices == 1);
		free_device_list(devices, num_devices);
	}
}
