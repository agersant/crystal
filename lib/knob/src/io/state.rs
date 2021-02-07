use core::ops::Deref;
use parking_lot::Mutex;
use std::sync::{mpsc::Sender, Arc};

use crate::io::device::DeviceAPI;
use crate::io::hal::HAL;
use crate::io::mode::Mode;

pub type StateHandle<T> = Arc<Mutex<State<T>>>;

pub struct State<T: HAL> {
	mode: Mode,
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
		}
	}

	pub fn set_mode(&mut self, mode: Mode) {
		self.mode = mode;
		if let Some(device) = &mut self.device {
			device.lock().set_mode(mode);
		}
	}

	pub fn is_connected(&self) -> bool {
		match &self.device {
			None => false,
			Some(device) => self.hal.is_device_valid(device.lock().deref()),
		}
	}

	pub fn connect(&mut self, port_number: usize) {
		self.device = self.hal.connect(port_number, self.mode).ok();
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
		state.connect(0);
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
		state.connect(0);
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
	state.connect(0);
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
	state.connect(0);
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
	state.connect(0);
	assert!(state.is_connected());
	state.hal = crate::io::hal::MockHardware {
		devices: Some(vec!["device 2".to_owned()]),
	};
	assert!(!state.is_connected());
}

#[test]
fn other_device_removal_does_not_cause_disconnect() {
	let hal = crate::io::hal::MockHardware {
		devices: Some(vec!["device 1".to_owned(), "device 2".to_owned()]),
	};
	let mut state = State::new(hal);
	state.connect(1);
	assert!(state.is_connected());
	state.hal = crate::io::hal::MockHardware {
		devices: Some(vec!["device 2".to_owned()]),
	};
	assert!(state.is_connected());
}

#[test]
fn mode_change_does_not_cause_disconnect() {
	let hal = crate::io::hal::MockHardware {
		devices: Some(vec!["device 1".to_owned(), "device 2".to_owned()]),
	};
	let mut state = State::new(hal);
	state.connect(0);
	state.set_mode(Mode::Absolute);
	assert!(state.is_connected());
	state.set_mode(Mode::RelativeArturia1);
	assert!(state.is_connected());
}

#[test]
fn mode_change_applies_to_current_device() {
	let hal = crate::io::hal::MockHardware {
		devices: Some(vec!["device 1".to_owned(), "device 2".to_owned()]),
	};
	let mut state = State::new(hal);
	state.connect(0);
	state.set_mode(Mode::RelativeArturia1);
	assert_eq!(state.device.unwrap().lock().mode(), Mode::RelativeArturia1);
}

#[test]
fn mode_change_applies_to_future_device() {
	let hal = crate::io::hal::MockHardware {
		devices: Some(vec!["device 1".to_owned(), "device 2".to_owned()]),
	};
	let mut state = State::new(hal);
	state.set_mode(Mode::RelativeArturia1);
	state.connect(0);
	assert_eq!(state.device.unwrap().lock().mode(), Mode::RelativeArturia1);
}
