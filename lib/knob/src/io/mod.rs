use std::cell::RefCell;

use connector::MIDIConnector;
use device::DeviceAPI;
pub use mode::Mode;
use state::State;

mod connector;
mod device;
mod mode;
mod state;

thread_local! {
	pub static STATE: RefCell<State<MIDIConnector>> = RefCell::new(State::new(MIDIConnector {}));
}

pub fn connect(port_number: usize) {
	STATE.with(|s| s.borrow_mut().set_port_number(port_number));
}

pub fn set_mode(mode: Mode) {
	STATE.with(|s| s.borrow_mut().set_mode(mode));
}

pub fn read_knob(cc_index: u8) -> f32 {
	STATE.with(|s| {
		s.borrow()
			.device
			.as_ref()
			.map(|d| d.lock().read(cc_index))
			.unwrap_or(-1.0)
	})
}

pub fn write_knob(cc_index: u8, value: f32) {
	STATE.with(|s| {
		if let Some(device) = &mut s.borrow_mut().device {
			device.lock().write(cc_index, value);
		}
	});
}

pub fn disconnect() {
	STATE.with(|s| {
		s.borrow_mut().device = None;
	});
}
