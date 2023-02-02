use lazy_static::lazy_static;

mod c_api;
mod io;

lazy_static! {
    pub static ref MIDI_HARDWARE_STATE: io::state::StateHandle<io::hal::MidiHardware> =
        io::state::State::new(io::hal::MidiHardware {});
}

#[cfg(test)]
lazy_static! {
    pub static ref SAMPLE_HARDWARE_STATE: io::state::StateHandle<io::hal::SampleHardware> =
        io::state::State::new(io::hal::SampleHardware {});
}
