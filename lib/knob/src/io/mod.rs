use std::sync::mpsc::*;
use std::time::Duration;

use device::DeviceAPI;
use hal::HAL;
use mode::Mode;
use state::StateHandle;

pub mod device;
pub mod hal;
pub mod mode;
pub mod state;

pub fn connect<T: HAL>(state: StateHandle<T>, port_number: usize) {
	let (sender, receiver) = channel::<()>();
	{
		let mut state = state.lock();
		state.connection_loop = Some(sender);
		state.disconnect();
	}
	std::thread::spawn(move || loop {
		{
			let mut state = state.lock();
			match receiver.try_recv() {
				Err(TryRecvError::Disconnected) => return,
				_ => (),
			}
			if !state.is_connected() {
				state.connect(port_number);
			}
		}
		std::thread::sleep(Duration::from_millis(500));
	});
}

pub fn list_devices<T: HAL>(state: StateHandle<T>) -> Vec<String> {
	let state = state.lock();
	state.hal.list_devices().unwrap_or_default()
}

pub fn set_mode<T: HAL>(state: StateHandle<T>, mode: Mode) {
	let mut state = state.lock();
	state.set_mode(mode);
}

pub fn read_knob<T: HAL>(state: StateHandle<T>, cc_index: u8) -> f32 {
	let state = state.lock();
	state
		.device
		.as_ref()
		.map(|d| d.lock().read(cc_index))
		.unwrap_or(-1.0)
}

pub fn write_knob<T: HAL>(state: StateHandle<T>, cc_index: u8, value: f32) {
	let mut state = state.lock();
	if let Some(device) = &mut state.device {
		device.lock().write(cc_index, value);
	}
}

pub fn disconnect<T: HAL>(state: StateHandle<T>) {
	let mut state = state.lock();
	state.connection_loop = None;
	state.disconnect();
}
