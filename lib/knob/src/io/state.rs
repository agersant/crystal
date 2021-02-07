use crate::io::connector::Connector;
use crate::io::mode::Mode;
use parking_lot::Mutex;
use std::sync::Arc;

pub struct State<T: Connector> {
	mode: Mode,
	port_number: usize,
	pub device: Option<Arc<Mutex<T::Device>>>,
	connector: T,
}

impl<T: Connector> State<T> {
	pub fn new(connector: T) -> Self {
		State {
			mode: Mode::Absolute,
			device: None,
			connector,
			port_number: 0,
		}
	}

	pub fn set_mode(&mut self, mode: Mode) {
		if mode == self.mode {
			return;
		}
		self.mode = mode;
		self.connect();
	}

	pub fn set_port_number(&mut self, port_number: usize) {
		if port_number == self.port_number {
			return;
		}
		self.port_number = port_number;
		self.connect();
	}

	pub fn connect(&mut self) {
		self.device = None;
		let device = self.connector.connect(self.port_number, self.mode);
		if let Err(e) = &device {
			println!("Error connecting to MIDI device: {}", e);
		}
		self.device = device.ok();
	}
}
