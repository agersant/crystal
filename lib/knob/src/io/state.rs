use parking_lot::Mutex;
use std::sync::{mpsc::Sender, Arc};

use crate::io::connector::Connector;
use crate::io::device::DeviceAPI;
use crate::io::mode::Mode;

pub struct State<T: Connector> {
	pub mode: Mode,
	pub port_number: usize,
	pub device: Option<Arc<Mutex<T::Device>>>,
	pub connection_loop: Option<Sender<()>>,
	pub connector: T,
}

impl<T: Connector> State<T> {
	pub fn new(connector: T) -> Self {
		State {
			mode: Mode::Absolute,
			device: None,
			connector,
			connection_loop: None,
			port_number: 0,
		}
	}

	pub fn is_connected(&self) -> bool {
		match &self.device {
			None => false,
			Some(device) => {
				let devices = self.connector.list_devices().unwrap_or_default();
				if self.port_number >= devices.len() {
					false
				} else {
					devices[self.port_number] == device.lock().name()
				}
			}
		}
	}

	pub fn connect(&mut self) {
		self.device = self.connector.connect(self.port_number, self.mode).ok();
	}

	pub fn disconnect(&mut self) {
		self.device = None;
	}
}
