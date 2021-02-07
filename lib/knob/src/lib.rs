use lazy_static::lazy_static;
use parking_lot::Mutex;
use std::sync::Arc;

mod c_api;
mod io;

lazy_static! {
	pub static ref MIDI_HARDWARE_STATE: io::state::StateHandle<io::hal::MidiHardware> =
		Arc::new(Mutex::new(io::state::State::new(io::hal::MidiHardware {})));
}

#[cfg(test)]
lazy_static! {
	pub static ref SAMPLE_HARDWARE_STATE: io::state::StateHandle<io::hal::SampleHardware> =
		Arc::new(Mutex::new(io::state::State::new(
			io::hal::SampleHardware {}
		)));
}
