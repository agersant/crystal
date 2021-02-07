use lazy_static::lazy_static;
use parking_lot::Mutex;
use std::sync::{mpsc::*, Arc};
use std::time::Duration;

use device::DeviceAPI;
use hal::{MidiHardware, HAL};
pub use mode::Mode;
use state::State;

mod device;
mod hal;
mod mode;
mod state;

lazy_static! {
	static ref STATE: Arc<Mutex<State<MidiHardware>>> =
		Arc::new(Mutex::new(State::new(MidiHardware {})));
}

pub fn connect() {
	let (sender, receiver) = channel::<()>();
	{
		let mut state = STATE.lock();
		state.connection_loop = Some(sender);
	}
	std::thread::spawn(move || loop {
		{
			let mut state = STATE.lock();
			if !state.is_connected() {
				state.connect();
			}
		}
		std::thread::sleep(Duration::from_millis(500));
		match receiver.try_recv() {
			Err(TryRecvError::Disconnected) => return,
			_ => continue,
		}
	});
}

pub fn list_devices() -> Vec<String> {
	let state = STATE.lock();
	state.hal.list_devices().unwrap_or_default()
}

pub fn get_port_number() -> usize {
	let state = STATE.lock();
	state.port_number
}

pub fn set_port_number(port_number: usize) {
	let mut state = STATE.lock();
	if state.port_number == port_number {
		return;
	}
	state.port_number = port_number;
	state.device = None;
}

pub fn set_mode(mode: Mode) {
	let mut state = STATE.lock();
	if state.mode == mode {
		return;
	}
	state.mode = mode;
	state.device = None;
}

pub fn read_knob(cc_index: u8) -> f32 {
	let state = STATE.lock();
	state
		.device
		.as_ref()
		.map(|d| d.lock().read(cc_index))
		.unwrap_or(-1.0)
}

pub fn write_knob(cc_index: u8, value: f32) {
	let mut state = STATE.lock();
	if let Some(device) = &mut state.device {
		device.lock().write(cc_index, value);
	}
}

pub fn disconnect() {
	let mut state = STATE.lock();
	state.connection_loop = None;
	state.disconnect();
}
