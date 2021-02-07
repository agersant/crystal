use anyhow::{anyhow, Context};
use lazy_static::lazy_static;
use midir::*;
use parking_lot::Mutex;

use crate::io::device::{Device, DeviceAPI};
pub use crate::io::mode::Mode;

mod device;
mod mode;

lazy_static! {
	static ref STATE: Mutex<State<MIDIConnector>> = Mutex::new(State::new(MIDIConnector {}));
}

trait Connector {
	type Device: DeviceAPI;
	fn connect(&self, port_number: usize, mode: Mode) -> Result<Self::Device, anyhow::Error>;
}

struct DummyConnector {}
impl Connector for DummyConnector {
	type Device = Device<()>;
	fn connect(&self, _port_number: usize, mode: Mode) -> Result<Self::Device, anyhow::Error> {
		Ok(Device::new("dummy", mode, ()))
	}
}

struct MIDIConnector {}
impl Connector for MIDIConnector {
	type Device = Device<MidiInputConnection<()>>;
	fn connect(&self, port_number: usize, mode: Mode) -> Result<Self::Device, anyhow::Error> {
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

		let connection = midi_input
			.connect(
				port,
				"crystal-knob-input-port",
				move |_, message, _| {
					let mut state = STATE.lock();
					if let Some(device) = &mut state.device {
						device.handle_message(message);
					}
				},
				(),
			)
			.context("Failed to establish MIDI input connection")?;

		println!("Connected to {}", device_name);

		let device = Device::new(device_name, mode, connection);
		Ok(device)
	}
}

struct State<T: Connector> {
	mode: Mode,
	port_number: usize,
	device: Option<T::Device>,
	connector: T,
}

impl<T: Connector> State<T> {
	fn new(connector: T) -> Self {
		State {
			mode: Mode::Absolute,
			device: None,
			connector,
			port_number: 0,
		}
	}

	fn set_mode(&mut self, mode: Mode) {
		self.mode = mode;
		self.connect();
	}

	fn connect(&mut self) {
		self.device = None;
		let device = self.connector.connect(self.port_number, self.mode);
		if let Err(e) = &device {
			println!("Error connecting to MIDI device: {}", e);
		}
		self.device = device.ok();
	}
}

pub fn connect(port_number: usize) {
	let mut state = STATE.lock();
	state.port_number = port_number;
	state.connect();
}

pub fn set_mode(mode: Mode) {
	let mut state = STATE.lock();
	state.set_mode(mode)
}

pub fn read_knob(cc_index: u8) -> f32 {
	let state = STATE.lock();
	state
		.device
		.as_ref()
		.map(|d| d.read(cc_index))
		.unwrap_or(-1.0)
}

pub fn write_knob(cc_index: u8, value: f32) {
	let mut state = STATE.lock();
	if let Some(device) = &mut state.device {
		device.write(cc_index, value);
	}
}

pub fn disconnect() {
	let mut state = STATE.lock();
	state.device = None;
}
