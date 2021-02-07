use anyhow::{anyhow, Context};
use midir::{MidiInput, MidiInputConnection};
use parking_lot::Mutex;
use std::sync::Arc;

use crate::io::device::{Device, DeviceAPI};
pub use crate::io::mode::Mode;

pub trait Connector {
	type Device: DeviceAPI;
	fn connect(
		&self,
		port_number: usize,
		mode: Mode,
	) -> Result<Arc<Mutex<Self::Device>>, anyhow::Error>;
}
struct DummyConnector {}
impl Connector for DummyConnector {
	type Device = Device<()>;
	fn connect(
		&self,
		_port_number: usize,
		mode: Mode,
	) -> Result<Arc<Mutex<Self::Device>>, anyhow::Error> {
		Ok(Arc::new(Mutex::new(Device::<()>::new("dummy", mode))))
	}
}

pub struct MIDIConnector {}

impl Connector for MIDIConnector {
	type Device = Device<MidiInputConnection<()>>;
	fn connect(
		&self,
		port_number: usize,
		mode: Mode,
	) -> Result<Arc<Mutex<Self::Device>>, anyhow::Error> {
		let midi_input: MidiInput =
			MidiInput::new("crystal-knob-client-input").context("Failed to create MIDI input")?;

		let ports = midi_input.ports();
		if ports.len() == 0 {
			return Err(anyhow!("No MIDI devices connected"));
		}
		if port_number >= ports.len() {
			return Err(anyhow!("No MIDI device exists on port {}", port_number));
		}

		let port = &ports[port_number];
		let device_name = midi_input
			.port_name(port)
			.unwrap_or("Unknown MIDI device".to_owned());

		let device = Arc::new(Mutex::new(Device::new(&device_name, mode)));
		let connection_device = device.clone();
		let connection = midi_input
			.connect(
				port,
				"crystal-knob-input-port",
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
}
