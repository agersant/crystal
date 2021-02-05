use anyhow::{anyhow, Context};
use lazy_static::lazy_static;
use midir::*;
use parking_lot::Mutex;
use std::collections::HashMap;

static MIDI_MESSAGE_CONTROL_CHANGE: u8 = 176;

lazy_static! {
	static ref STATE: Mutex<State> = Mutex::new(State::default());
}

struct State {
	connection: Option<MidiInputConnection<()>>,
	knob_values: HashMap<u8, u8>,
}

impl Default for State {
	fn default() -> Self {
		State {
			connection: None,
			knob_values: HashMap::new(),
		}
	}
}

impl State {
	fn reset(&mut self) {
		*self = Self::default();
	}

	fn handle_message(&mut self, message: &[u8]) {
		if message.len() < 3 {
			return;
		}
		if message[0] != MIDI_MESSAGE_CONTROL_CHANGE {
			return;
		}
		let cc_index = message[1];
		let knob_value = message[2];
		println!("value {}", knob_value);
		self.knob_values.insert(cc_index, knob_value);
	}
}

fn try_connect(port_number: usize) -> Result<MidiInputConnection<()>, anyhow::Error> {
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
				state.handle_message(message);
			},
			(),
		)
		.context("Failed to establish MIDI input connection")?;

	println!("Connected to {}", device_name);
	Ok(connection)
}

pub fn connect(port_number: usize) {
	let mut state = STATE.lock();
	state.reset();
	let connection = try_connect(port_number);
	if let Err(e) = &connection {
		println!("Error connecting to MIDI device: {}", e);
	}
	state.connection = connection.ok();
}

pub fn disconnect() {
	let mut state = STATE.lock();
	state.reset();
}

pub fn read_knob(cc_index: u8) -> f32 {
	let state = STATE.lock();
	state
		.knob_values
		.get(&cc_index)
		.map(|n| (*n as f32) / 127.0)
		.unwrap_or(-1.0)
}
