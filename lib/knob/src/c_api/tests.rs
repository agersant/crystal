use crate::c_api::*;

#[test]
fn omnibus() {
	unsafe {
		assert_eq!(read_knob(70), -1.0);
		connect(0);
		set_mode(io::Mode::Absolute);
		write_knob(70, 1.0);
		assert_eq!(read_knob(70), 1.0);
		disconnect();
	}
}
