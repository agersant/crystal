use crate::io;

#[no_mangle]
pub unsafe extern "C" fn connect(port_number: usize) {
	io::connect(port_number);
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
		connect(0);
		set_mode(io::Mode::Absolute);
		write_knob(70, 1.0);
		read_knob(70);
		disconnect();
	}
}
