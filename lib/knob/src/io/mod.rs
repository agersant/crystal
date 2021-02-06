use anyhow::{anyhow, Context};
use lazy_static::lazy_static;
use midir::*;
use parking_lot::Mutex;
use std::collections::HashMap;

static MIDI_MESSAGE_CONTROL_CHANGE: u8 = 176;

lazy_static! {
	static ref STATE: Mutex<State> = Mutex::new(State::default());
}

// https://www.yamahasynth.com/ask-a-question/relative-mode-for-control-knobs#reply-102919
#[repr(C)]
pub enum Mode {
	Absolute,
	RelativeArturia1,
}

struct State {
	connection: Option<MidiInputConnection<()>>,
	mode: Mode,
	knob_values: HashMap<u8, f32>,
}

impl Default for State {
	fn default() -> Self {
		State {
			connection: None,
			mode: Mode::Absolute,
			knob_values: HashMap::new(),
		}
	}
}

impl State {
	fn reset(&mut self) {
		*self = Self::default();
	}

	fn set_mode(&mut self, mode: Mode) {
		self.mode = mode;
		self.knob_values.clear();
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

		self.write_knob(cc_index, new_value);
	}

	pub fn read_knob(&self, cc_index: u8) -> f32 {
		self.knob_values.get(&cc_index).copied().unwrap_or(-1.0)
	}

	pub fn write_knob(&mut self, cc_index: u8, value: f32) {
		self.knob_values.insert(cc_index, value.min(1.0).max(0.0));
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

pub fn set_mode(mode: Mode) {
	let mut state = STATE.lock();
	state.set_mode(mode)
}

pub fn read_knob(cc_index: u8) -> f32 {
	let state = STATE.lock();
	state.read_knob(cc_index)
}

pub fn write_knob(cc_index: u8, value: f32) {
	let mut state = STATE.lock();
	state.write_knob(cc_index, value)
}

pub fn disconnect() {
	let mut state = STATE.lock();
	state.reset();
}

#[test]
fn initial_value() {
	let cc_index = 70;
	let state = State::default();
	assert_eq!(state.read_knob(cc_index), -1.0);
}

#[test]
fn absolute_mode_stores_custom_value() {
	let cc_index = 70;
	let mut state = State::default();
	state.set_mode(Mode::Absolute);
	state.write_knob(cc_index, 0.5);
	assert_eq!(state.read_knob(cc_index), 0.5);
}

#[test]
fn absolute_mode_stores_midi_value() {
	let cc_index = 70;
	let mut state = State::default();
	state.set_mode(Mode::Absolute);
	state.handle_message(&[MIDI_MESSAGE_CONTROL_CHANGE, cc_index, 100]);
	assert_eq!(state.read_knob(cc_index), 100.0 / 127.0);
}

#[test]
fn arturia1_mode_stores_custom_value() {
	let cc_index = 70;
	let mut state = State::default();
	state.set_mode(Mode::RelativeArturia1);
	state.write_knob(cc_index, 0.5);
	assert_eq!(state.read_knob(cc_index), 0.5);
}

#[test]
fn arturia1_mode_ignores_midi_before_write() {
	let cc_index = 70;
	let mut state = State::default();
	state.set_mode(Mode::RelativeArturia1);
	state.handle_message(&[MIDI_MESSAGE_CONTROL_CHANGE, cc_index, 64]);
	assert_eq!(state.read_knob(cc_index), -1.0);
}

#[test]
fn arturia1_mode_tracks_changes_after_write() {
	let cc_index = 70;
	let mut state = State::default();
	state.set_mode(Mode::RelativeArturia1);
	state.write_knob(cc_index, 0.5);
	assert_eq!(state.read_knob(cc_index), 0.5);
	state.handle_message(&[MIDI_MESSAGE_CONTROL_CHANGE, cc_index, 0x41]);
	assert_eq!(state.read_knob(cc_index), 0.5 + 1.0 / 127.0);
	state.handle_message(&[MIDI_MESSAGE_CONTROL_CHANGE, cc_index, 0x42]);
	assert_eq!(state.read_knob(cc_index), 0.5 + 3.0 / 127.0);
	state.handle_message(&[MIDI_MESSAGE_CONTROL_CHANGE, cc_index, 0x43]);
	assert_eq!(state.read_knob(cc_index), 0.5 + 6.0 / 127.0);
	state.handle_message(&[MIDI_MESSAGE_CONTROL_CHANGE, cc_index, 0x3F]);
	assert_eq!(state.read_knob(cc_index), 0.5 + 5.0 / 127.0);
	state.handle_message(&[MIDI_MESSAGE_CONTROL_CHANGE, cc_index, 0x3E]);
	assert_eq!(state.read_knob(cc_index), 0.5 + 3.0 / 127.0);
	state.handle_message(&[MIDI_MESSAGE_CONTROL_CHANGE, cc_index, 0x3D]);
	assert_eq!(state.read_knob(cc_index), 0.5);
}

#[test]
fn arturia1_clamps() {
	let cc_index = 70;

	{
		let mut state = State::default();
		state.set_mode(Mode::RelativeArturia1);
		state.write_knob(cc_index, 1.0);
		for _ in 0..10 {
			state.handle_message(&[MIDI_MESSAGE_CONTROL_CHANGE, cc_index, 0x43]);
		}
		assert_eq!(state.read_knob(cc_index), 1.0);
	}

	{
		let mut state = State::default();
		state.set_mode(Mode::RelativeArturia1);
		state.write_knob(cc_index, 0.0);
		for _ in 0..10 {
			state.handle_message(&[MIDI_MESSAGE_CONTROL_CHANGE, cc_index, 0x3D]);
		}
		assert_eq!(state.read_knob(cc_index), 0.0);
	}
}
