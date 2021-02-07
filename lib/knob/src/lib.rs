use lazy_static::lazy_static;
use parking_lot::Mutex;
use std::sync::Arc;

mod c_api;
mod io;

lazy_static! {
	pub static ref MIDI_HARDWARE_STATE: Arc<Mutex<io::state::State<io::hal::MidiHardware>>> =
		Arc::new(Mutex::new(io::state::State::new(io::hal::MidiHardware {})));
}
