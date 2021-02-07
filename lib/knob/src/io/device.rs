use std::collections::HashMap;
#[cfg(test)]
use strum::IntoEnumIterator;

static MIDI_MESSAGE_CONTROL_CHANGE: u8 = 176;

use crate::io::Mode;

pub trait DeviceAPI {
	fn read(&self, cc_index: u8) -> f32;
	fn write(&mut self, cc_index: u8, value: f32);
	fn handle_message(&mut self, message: &[u8]);
	fn name<'a>(&'a self) -> &'a str;
}

pub struct Device<T> {
	mode: Mode,
	name: String,
	connection: Option<T>,
	knob_values: HashMap<u8, f32>,
}

impl<T> Device<T> {
	pub fn new<S: Into<String>>(name: S, mode: Mode) -> Device<T> {
		Self {
			mode,
			name: name.into(),
			connection: None,
			knob_values: HashMap::new(),
		}
	}

	pub fn hold_connection(&mut self, connection: T) {
		self.connection = Some(connection);
	}
}

impl<T> DeviceAPI for Device<T> {
	fn read(&self, cc_index: u8) -> f32 {
		self.knob_values.get(&cc_index).copied().unwrap_or(-1.0)
	}

	fn write(&mut self, cc_index: u8, value: f32) {
		self.knob_values.insert(cc_index, value.min(1.0).max(0.0));
	}

	fn handle_message(&mut self, message: &[u8]) {
		if message.len() < 3 {
			return;
		}
		if message[0] != MIDI_MESSAGE_CONTROL_CHANGE {
			return;
		}
		let cc_index = message[1];
		let raw_value = message[2];

		let new_value = match self.mode {
			Mode::Absolute => raw_value as f32 / i8::MAX as f32,
			Mode::RelativeArturia1 => {
				if let Some(value) = self.knob_values.get(&cc_index).copied() {
					let delta = (raw_value as i8) - 0x40;
					let ux_tuning = 0.25;
					value + (ux_tuning * delta as f32 / i8::MAX as f32)
				} else {
					return;
				}
			}
		};

		self.write(cc_index, new_value);
	}

	fn name(&self) -> &str {
		&self.name
	}
}

#[test]
fn can_read_before_receiving_data() {
	let cc_index = 70;
	for mode in Mode::iter() {
		let device = Device::<()>::new("test device", mode);
		assert_eq!(device.read(cc_index), -1.0);
	}
}

#[test]
fn can_read_write_arbitrary_values() {
	let cc_index = 70;
	for mode in Mode::iter() {
		let mut device = Device::<()>::new("test device", mode);
		device.write(cc_index, 0.5);
		assert_eq!(device.read(cc_index), 0.5);
	}
}

#[test]
fn clamps_values() {
	let cc_index = 70;
	for mode in Mode::iter() {
		let mut device = Device::<()>::new("test device", mode);
		device.write(cc_index, 1.5);
		assert_eq!(device.read(cc_index), 1.0);
		device.write(cc_index, -0.5);
		assert_eq!(device.read(cc_index), 0.0);
	}
}

#[test]
fn absolute_mode_can_read_knob_values() {
	let cc_index = 70;
	let mut device = Device::<()>::new("test device", Mode::Absolute);
	device.handle_message(&[MIDI_MESSAGE_CONTROL_CHANGE, cc_index, 100]);
	assert_eq!(device.read(cc_index), 100.0 / 127.0);
}

#[test]
fn relative_modes_ignore_messages_before_write() {
	let cc_index = 70;
	for mode in Mode::iter() {
		if mode.is_absolute() {
			continue;
		}
		let mut device = Device::<()>::new("test device", mode);
		device.handle_message(&[MIDI_MESSAGE_CONTROL_CHANGE, cc_index, 64]);
		assert_eq!(device.read(cc_index), -1.0);
	}
}

#[test]
fn arturia1_mode_interprets_messages_correctly() {
	let cc_index = 70;
	let mut device = Device::<()>::new("test device", Mode::RelativeArturia1);

	for m in 0x41..=0x43 {
		device.write(cc_index, 0.5);
		device.handle_message(&[MIDI_MESSAGE_CONTROL_CHANGE, cc_index, m]);
		assert!(device.read(cc_index) > 0.5);
	}

	for m in 0x3D..=0x3F {
		device.write(cc_index, 0.5);
		device.handle_message(&[MIDI_MESSAGE_CONTROL_CHANGE, cc_index, m]);
		assert!(device.read(cc_index) < 0.5);
	}
}
