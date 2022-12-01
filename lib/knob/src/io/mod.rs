use device::DeviceAPI;
use hal::Hal;
use state::StateHandle;
use strum::EnumIter;

pub mod device;
pub mod hal;
pub mod state;

// https://www.yamahasynth.com/ask-a-question/relative-mode-for-control-knobs#reply-102919
#[repr(C)]
#[derive(Clone, Copy, Debug, EnumIter, PartialEq, Eq)]
pub enum Mode {
	Absolute,
	RelativeAkai,
	RelativeArturia1,
	RelativeArturia2,
	RelativeArturia3,
}

pub fn connect<T: Hal>(state: StateHandle<T>, port_number: usize) {
	let mut state = state.lock();
	state.connect(port_number);
}

pub fn list_devices<T: Hal>(state: StateHandle<T>) -> Vec<String> {
	let state = state.lock();
	state.hal.list_devices().unwrap_or_default()
}

pub fn get_current_device<T: Hal>(state: StateHandle<T>) -> Option<String> {
	let state = state.lock();
	state.device().map(|d| state.hal.get_device_name(&d.lock()))
}

pub fn set_mode<T: Hal>(state: StateHandle<T>, mode: Mode) {
	let mut state = state.lock();
	state.set_mode(mode);
}

pub fn read_knob<T: Hal>(state: StateHandle<T>, cc_index: u8) -> f32 {
	let state = state.lock();
	state
		.device()
		.map(|d| d.lock().read(cc_index))
		.unwrap_or(-1.0)
}

pub fn write_knob<T: Hal>(state: StateHandle<T>, cc_index: u8, value: f32) {
	let state = state.lock();
	if let Some(device) = state.device() {
		device.lock().write(cc_index, value);
	}
}

pub fn disconnect<T: Hal>(state: StateHandle<T>) {
	let mut state = state.lock();
	state.disconnect();
}
