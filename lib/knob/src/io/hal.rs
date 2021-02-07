use anyhow::{anyhow, Context};
use midir::{MidiInput, MidiInputConnection, MidiInputPort};
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

	fn is_device_valid(&self, device: &Self::Device) -> bool;
}

pub struct MidiHardware {}

impl MidiHardware {
	fn get_midi_input() -> Result<MidiInput, anyhow::Error> {
		MidiInput::new(MIDI_CLIENT_NAME).context("Failed to create MIDI input")
	}
}

impl HAL for MidiHardware {
	type Device = Device<MidiInputConnection<()>, MidiInputPort>;

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

		let device = Arc::new(Mutex::new(Device::new(&device_name, mode, port.clone())));
		let connection_device = device.clone();
		let connection = midi_input
			.connect(
				port,
				MIDI_PORT_NAME,
				move |_, message, _| {
					// TODO Pipe messages to a channel instead of having to directly reference the device
					connection_device.lock().handle_message(message);
				},
				(),
			)
			// TODO: https://github.com/Boddlnagg/midir/issues/55
			.map_err(|e| midir::ConnectError::new(e.kind(), ()))?;
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

	fn is_device_valid(&self, device: &Self::Device) -> bool {
		// TODO https://github.com/Boddlnagg/midir/issues/35
		// This code isn't reliable when multiple devices have the same name
		let device_name = Self::get_midi_input()
			.and_then(|m| m.port_name(&device.port()).map_err(|e| e.into()))
			.unwrap_or(UNKNOWN_DEVICE_NAME.to_owned());
		let devices = self.list_devices().unwrap_or_default();
		devices.iter().any(|name| *name == device_name)
	}
}

#[cfg(test)]
pub struct SampleHardware {}

#[cfg(test)]
impl HAL for SampleHardware {
	type Device = Device<(), ()>;

	fn connect(
		&self,
		_port_number: usize,
		mode: Mode,
	) -> Result<Arc<Mutex<Self::Device>>, anyhow::Error> {
		let device = Arc::new(Mutex::new(Device::new("sample_device", mode, ())));
		Ok(device)
	}

	fn list_devices(&self) -> Result<Vec<String>, anyhow::Error> {
		Ok(vec!["sample_device".to_owned()])
	}

	fn is_device_valid(&self, _device: &Self::Device) -> bool {
		true
	}
}

#[cfg(test)]
pub struct MockHardware {
	pub devices: Option<Vec<String>>,
}

#[cfg(test)]
impl HAL for MockHardware {
	type Device = Device<(), String>;

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
		let port = device_name.to_owned();
		let device = Arc::new(Mutex::new(Device::new(device_name, mode, port)));
		Ok(device)
	}

	fn list_devices(&self) -> Result<Vec<String>, anyhow::Error> {
		match &self.devices {
			None => Err(anyhow!("no device list")),
			Some(d) => Ok(d.clone()),
		}
	}

	fn is_device_valid(&self, device: &Self::Device) -> bool {
		self.list_devices()
			.unwrap_or_default()
			.contains(device.port())
	}
}
