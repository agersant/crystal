use anyhow::{anyhow, Context};
use midir::{MidiInput, MidiInputConnection};
use parking_lot::Mutex;
use std::sync::Arc;

use crate::io::device::{Device, DeviceAPI};
pub use crate::io::mode::Mode;

static MIDI_CLIENT_NAME: &'static str = "crystal-knob-client-input";
static MIDI_PORT_NAME: &'static str = "crystal-knob-input-port";
static UNKNOWN_DEVICE_NAME: &'static str = "Unknown MIDI Device";

pub trait HAL: Send + 'static {
	type Device: DeviceAPI + Send;

	fn connect(
		&self,
		port_number: usize,
		mode: Mode,
	) -> Result<Arc<Mutex<Self::Device>>, anyhow::Error>;

	fn list_devices(&self) -> Result<Vec<String>, anyhow::Error>;
}

pub struct MidiHardware {}

impl MidiHardware {
	fn get_midi_input() -> Result<MidiInput, anyhow::Error> {
		MidiInput::new(MIDI_CLIENT_NAME).context("Failed to create MIDI input")
	}
}

impl HAL for MidiHardware {
	type Device = Device<MidiInputConnection<()>>;

	fn connect(
		&self,
		port_number: usize,
		mode: Mode,
	) -> Result<Arc<Mutex<Self::Device>>, anyhow::Error> {
		let midi_input = Self::get_midi_input()?;
		let ports = midi_input.ports();
		if ports.len() == 0 {
			return Err(anyhow!("No MIDI devices detected"));
		}

		if port_number >= ports.len() {
			return Err(anyhow!("No MIDI device exists on port {}", port_number));
		}

		let port = &ports[port_number];
		let device_name = midi_input
			.port_name(port)
			.unwrap_or(UNKNOWN_DEVICE_NAME.to_owned());

		let device = Arc::new(Mutex::new(Device::new(&device_name, mode)));
		let connection_device = device.clone();
		let connection = midi_input
			.connect(
				port,
				MIDI_PORT_NAME,
				move |_, message, _| {
					connection_device.lock().handle_message(message);
				},
				(),
			)
			.map_err(|e| anyhow!(format!("MIDI connection error: {}", e)))?;
		device.lock().hold_connection(connection);

		println!("Connected to {}", device_name);

		Ok(device)
	}

	fn list_devices(&self) -> Result<Vec<String>, anyhow::Error> {
		let midi_input = Self::get_midi_input()?;
		let devices = midi_input
			.ports()
			.iter()
			.map(|port| {
				midi_input
					.port_name(port)
					.unwrap_or(UNKNOWN_DEVICE_NAME.to_owned())
			})
			.collect();
		Ok(devices)
	}
}

#[cfg(test)]
pub struct SampleHardware {}

#[cfg(test)]
impl HAL for SampleHardware {
	type Device = Device<()>;

	fn connect(
		&self,
		_port_number: usize,
		mode: Mode,
	) -> Result<Arc<Mutex<Self::Device>>, anyhow::Error> {
		let device = Arc::new(Mutex::new(Device::new("sample_device", mode)));
		Ok(device)
	}

	fn list_devices(&self) -> Result<Vec<String>, anyhow::Error> {
		Ok(vec!["sample_device".to_owned()])
	}
}

#[cfg(test)]
pub struct MockHardware {
	pub devices: Option<Vec<String>>,
}

#[cfg(test)]
impl HAL for MockHardware {
	type Device = Device<()>;

	fn connect(
		&self,
		port_number: usize,
		mode: Mode,
	) -> Result<Arc<Mutex<Self::Device>>, anyhow::Error> {
		let devices = self.list_devices().unwrap_or_default();
		if port_number >= devices.len() {
			return Err(anyhow!("No device exists on port {}", port_number));
		}
		let device_name = self.devices.as_ref().unwrap()[port_number].as_str();
		let device = Arc::new(Mutex::new(Device::new(device_name, mode)));
		Ok(device)
	}

	fn list_devices(&self) -> Result<Vec<String>, anyhow::Error> {
		match &self.devices {
			None => Err(anyhow!("no device list")),
			Some(d) => Ok(d.clone()),
		}
	}
}
