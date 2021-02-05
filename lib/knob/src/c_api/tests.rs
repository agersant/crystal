use crate::c_api::*;

#[test]
fn lifecycle() {
	unsafe {
		assert_eq!(read_knob(70), -1.0);
		connect(0);
		assert_eq!(read_knob(70), -1.0);
		disconnect();
	}
}
