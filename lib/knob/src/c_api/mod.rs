use crate::io;

#[cfg(test)]
mod tests;

#[no_mangle]
pub unsafe extern "C" fn connect(port_number: usize) {
	io::connect(port_number);
}

#[no_mangle]
pub unsafe extern "C" fn read_knob(cc_index: u8) -> f32 {
	io::read_knob(cc_index)
}

#[no_mangle]
pub unsafe extern "C" fn disconnect() {
	io::disconnect();
}
