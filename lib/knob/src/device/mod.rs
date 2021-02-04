use anyhow::{anyhow, Context};
use midir::*;

pub struct Device {
	_connection: Option<MidiInputConnection<()>>,
}

impl Device {
	fn connect() -> Result<MidiInputConnection<()>, anyhow::Error> {
		let midi_input: MidiInput =
			MidiInput::new("crystal-knob-client-input").context("Failed to create MIDI input")?;
		let ports = midi_input.ports();

		if ports.len() == 0 {
			return Err(anyhow!("No MIDI devices connected"));
		}
		let port = &ports[0];
		let device_name = midi_input
			.port_name(port)
			.unwrap_or("Unknown MIDI device".to_owned());
		println!("Connecting to {}…", device_name);

		let connection = midi_input
			.connect(
				port,
				"crystal-knob-input-port",
				move |stamp, message, _| {
					println!("{}: {:?} (len = {})", stamp, message, message.len());
				},
				(),
			)
			.context("Failed to establish MIDI input connection")?;

		println!("Connected to {}", device_name);
		Ok(connection)
	}

	pub fn new() -> Device {
		let connection = Self::connect();
		if let Err(e) = &connection {
			println!("Error creating Knob device: {}", e);
		}
		Device {
			_connection: connection.ok(),
		}
	}
}
