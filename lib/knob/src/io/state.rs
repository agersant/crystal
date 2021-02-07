use parking_lot::Mutex;
use std::sync::{mpsc::Sender, Arc};

use crate::io::device::DeviceAPI;
use crate::io::hal::HAL;
use crate::io::mode::Mode;

pub type StateHandle<T> = Arc<Mutex<State<T>>>;

pub struct State<T: HAL> {
	pub mode: Mode,
	pub port_number: usize,
	pub device: Option<Arc<Mutex<T::Device>>>,
	pub connection_loop: Option<Sender<()>>,
	pub hal: T,
}

impl<T: HAL> State<T> {
	pub fn new(hal: T) -> Self {
		State {
			mode: Mode::Absolute,
			device: None,
			hal,
			connection_loop: None,
			port_number: 0,
		}
	}

	pub fn is_connected(&self) -> bool {
		match &self.device {
			None => false,
			Some(device) => {
				let devices = self.hal.list_devices().unwrap_or_default();
				if self.port_number >= devices.len() {
					false
				} else {
					devices[self.port_number] == device.lock().name()
				}
			}
		}
	}

	pub fn connect(&mut self) {
		self.device = self.hal.connect(self.port_number, self.mode).ok();
	}

	pub fn disconnect(&mut self) {
		self.device = None;
	}
}

#[test]
fn fails_to_connect_without_device_list() {
	{
		let hal = crate::io::hal::MockHardware { devices: None };
		let mut state = State::new(hal);
		state.connect();
		assert!(!state.is_connected());
	}
}

#[test]
fn fails_to_connect_with_empty_device_list() {
	{
		let hal = crate::io::hal::MockHardware {
			devices: Some(vec![]),
		};
		let mut state = State::new(hal);
		state.connect();
		assert!(!state.is_connected());
	}
}

#[test]
fn keeps_track_of_connection() {
	let hal = crate::io::hal::MockHardware {
		devices: Some(vec!["device 1".to_owned()]),
	};
	let mut state = State::new(hal);
	assert!(!state.is_connected());
	state.connect();
	assert!(state.is_connected());
	state.disconnect();
	assert!(!state.is_connected());
}

#[test]
fn loss_of_device_list_causes_disconnect() {
	let hal = crate::io::hal::MockHardware {
		devices: Some(vec!["device 1".to_owned(), "device 2".to_owned()]),
	};
	let mut state = State::new(hal);
	state.connect();
	assert!(state.is_connected());

	state.hal = crate::io::hal::MockHardware { devices: None };
	assert!(!state.is_connected());
}

#[test]
fn device_removal_causes_disconnect() {
	let hal = crate::io::hal::MockHardware {
		devices: Some(vec!["device 1".to_owned(), "device 2".to_owned()]),
	};
	let mut state = State::new(hal);
	state.connect();
	assert!(state.is_connected());

	state.hal = crate::io::hal::MockHardware {
		devices: Some(vec!["device 2".to_owned()]),
	};
	assert!(!state.is_connected());
}
