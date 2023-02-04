use parking_lot::Mutex;
use std::collections::HashMap;
use std::sync::{mpsc::*, Arc};
#[cfg(test)]
use strum::IntoEnumIterator;

use crate::Mode;

static MIDI_MESSAGE_CONTROL_CHANGE: u8 = 176;

pub(crate) trait DeviceAPI: Send {
    type Port: Clone + Send;
    fn set_mode(&mut self, mode: Mode);
    fn read(&self, cc_index: u8) -> f32;
    fn write(&mut self, cc_index: u8, value: f32);
    fn handle_message(&mut self, message: &[u8]);
    fn name(&self) -> &str;
    fn mode(&self) -> Mode;
    fn port(&self) -> &Self::Port;
    fn drop_connection(&mut self);
}

pub(crate) struct Device<C, P> {
    mode: Mode,
    name: String,
    port: P,
    connection: Option<C>,
    knob_values: HashMap<u8, f32>,
}

impl<C: Send + 'static, P: Clone + Send + 'static> Device<C, P> {
    pub fn new<S: Into<String>>(
        name: S,
        mode: Mode,
        port: P,
        connection: C,
        receiver: Receiver<Vec<u8>>,
    ) -> Arc<Mutex<Device<C, P>>> {
        let device = Arc::new(Mutex::new(Self {
            mode,
            name: name.into(),
            port,
            connection: Some(connection),
            knob_values: HashMap::new(),
        }));

        let receive_device = device.clone();
        std::thread::spawn(move || loop {
            match receiver.recv() {
                Ok(message) => {
                    let mut device = receive_device.lock();
                    device.handle_message(&message);
                }
                Err(_) => return,
            }
        });

        device
    }
}

impl<T: Send, P: Clone + Send> DeviceAPI for Device<T, P> {
    type Port = P;

    fn set_mode(&mut self, mode: Mode) {
        self.mode = mode;
    }

    fn read(&self, cc_index: u8) -> f32 {
        self.knob_values.get(&cc_index).copied().unwrap_or(-1.0)
    }

    fn write(&mut self, cc_index: u8, value: f32) {
        self.knob_values.insert(cc_index, value.clamp(0.0, 1.0));
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
            Mode::RelativeAkai => {
                if let Some(value) = self.knob_values.get(&cc_index).copied() {
                    let delta = match raw_value {
                        0x01..=0x3F => raw_value as i8,
                        0x40..=0x7F => -((0x80 - raw_value) as i8),
                        _ => return,
                    };
                    let ux_tuning = 0.25; // Untested
                    value + (ux_tuning * delta as f32 / i8::MAX as f32)
                } else {
                    return;
                }
            }
            Mode::RelativeArturia1 => {
                if let Some(value) = self.knob_values.get(&cc_index).copied() {
                    let delta = (raw_value as i8) - 0x40;
                    let ux_tuning = 0.25;
                    value + (ux_tuning * delta as f32 / i8::MAX as f32)
                } else {
                    return;
                }
            }
            Mode::RelativeArturia2 => {
                if let Some(value) = self.knob_values.get(&cc_index).copied() {
                    let delta = match raw_value {
                        0x01..=0x03 => raw_value as i8,
                        0x7D..=0x7F => -((0x80 - raw_value) as i8),
                        _ => return,
                    };
                    let ux_tuning = 0.25;
                    value + (ux_tuning * delta as f32 / i8::MAX as f32)
                } else {
                    return;
                }
            }
            Mode::RelativeArturia3 => {
                if let Some(value) = self.knob_values.get(&cc_index).copied() {
                    let delta = (raw_value as i8) - 0x10;
                    let ux_tuning = 0.25;
                    value + (ux_tuning * delta as f32 / i8::MAX as f32)
                } else {
                    return;
                }
            }
        };

        self.write(cc_index, new_value);
    }

    fn name(&self) -> &str {
        &self.name
    }

    fn mode(&self) -> Mode {
        self.mode
    }

    fn port(&self) -> &P {
        &self.port
    }

    fn drop_connection(&mut self) {
        self.connection = None;
    }
}

#[cfg(test)]
mod tests {

    use super::*;

    type TestDevice = Device<(), ()>;

    fn make_test_device(mode: Mode) -> (Arc<Mutex<TestDevice>>, Sender<Vec<u8>>) {
        let (sender, receiver) = channel();
        let device = Device::<(), ()>::new("test device", mode, (), (), receiver);
        (device, sender)
    }

    #[test]
    fn can_read_before_receiving_data() {
        let cc_index = 70;
        for mode in Mode::iter() {
            let (device, _) = make_test_device(mode);
            assert_eq!(device.lock().read(cc_index), -1.0);
        }
    }

    #[test]
    fn can_read_write_arbitrary_values() {
        let cc_index = 70;
        for mode in Mode::iter() {
            let (device, _) = make_test_device(mode);
            device.lock().write(cc_index, 0.5);
            assert_eq!(device.lock().read(cc_index), 0.5);
        }
    }

    #[test]
    fn clamps_values() {
        let cc_index = 70;
        for mode in Mode::iter() {
            let (device, _) = make_test_device(mode);
            device.lock().write(cc_index, 1.5);
            assert_eq!(device.lock().read(cc_index), 1.0);
            device.lock().write(cc_index, -0.5);
            assert_eq!(device.lock().read(cc_index), 0.0);
        }
    }

    #[test]
    fn absolute_mode_can_read_knob_values() {
        let cc_index = 70;
        let (device, _) = make_test_device(Mode::Absolute);
        device
            .lock()
            .handle_message(&[MIDI_MESSAGE_CONTROL_CHANGE, cc_index, 100]);
        assert_eq!(device.lock().read(cc_index), 100.0 / 127.0);
    }

    #[test]
    fn handles_messages_from_sender() {
        let cc_index = 70;
        let (device, sender) = make_test_device(Mode::Absolute);
        sender
            .send([MIDI_MESSAGE_CONTROL_CHANGE, cc_index, 100].to_vec())
            .unwrap();
        std::thread::sleep(std::time::Duration::from_millis(100));
        assert_eq!(device.lock().read(cc_index), 100.0 / 127.0);
    }

    #[test]
    fn relative_modes_ignore_messages_before_write() {
        let cc_index = 70;
        for mode in Mode::iter() {
            if matches!(mode, Mode::Absolute) {
                continue;
            }
            let (device, _) = make_test_device(mode);
            device
                .lock()
                .handle_message(&[MIDI_MESSAGE_CONTROL_CHANGE, cc_index, 64]);
            assert_eq!(device.lock().read(cc_index), -1.0);
        }
    }

    #[test]
    fn akai_mode_interprets_messages_correctly() {
        let cc_index = 70;
        let (device, _) = make_test_device(Mode::RelativeAkai);

        for m in 0x01..=0x3F {
            device.lock().write(cc_index, 0.5);
            device
                .lock()
                .handle_message(&[MIDI_MESSAGE_CONTROL_CHANGE, cc_index, m]);
            assert!(device.lock().read(cc_index) > 0.5);
        }

        for m in 0x40..=0x7F {
            device.lock().write(cc_index, 0.5);
            device
                .lock()
                .handle_message(&[MIDI_MESSAGE_CONTROL_CHANGE, cc_index, m]);
            assert!(device.lock().read(cc_index) < 0.5);
        }
    }

    #[test]
    fn arturia1_mode_interprets_messages_correctly() {
        let cc_index = 70;
        let (device, _) = make_test_device(Mode::RelativeArturia1);

        for m in 0x41..=0x43 {
            device.lock().write(cc_index, 0.5);
            device
                .lock()
                .handle_message(&[MIDI_MESSAGE_CONTROL_CHANGE, cc_index, m]);
            assert!(device.lock().read(cc_index) > 0.5);
        }

        for m in 0x3D..=0x3F {
            device.lock().write(cc_index, 0.5);
            device
                .lock()
                .handle_message(&[MIDI_MESSAGE_CONTROL_CHANGE, cc_index, m]);
            assert!(device.lock().read(cc_index) < 0.5);
        }
    }

    #[test]
    fn arturia2_mode_interprets_messages_correctly() {
        let cc_index = 70;
        let (device, _) = make_test_device(Mode::RelativeArturia2);

        for m in 0x01..=0x03 {
            device.lock().write(cc_index, 0.5);
            device
                .lock()
                .handle_message(&[MIDI_MESSAGE_CONTROL_CHANGE, cc_index, m]);
            assert!(device.lock().read(cc_index) > 0.5);
        }

        for m in 0x7D..=0x7F {
            device.lock().write(cc_index, 0.5);
            device
                .lock()
                .handle_message(&[MIDI_MESSAGE_CONTROL_CHANGE, cc_index, m]);
            assert!(device.lock().read(cc_index) < 0.5);
        }
    }

    #[test]
    fn arturia3_mode_interprets_messages_correctly() {
        let cc_index = 70;
        let (device, _) = make_test_device(Mode::RelativeArturia3);

        for m in 0x11..=0x13 {
            device.lock().write(cc_index, 0.5);
            device
                .lock()
                .handle_message(&[MIDI_MESSAGE_CONTROL_CHANGE, cc_index, m]);
            assert!(device.lock().read(cc_index) > 0.5);
        }

        for m in 0x0D..=0x0F {
            device.lock().write(cc_index, 0.5);
            device
                .lock()
                .handle_message(&[MIDI_MESSAGE_CONTROL_CHANGE, cc_index, m]);
            assert!(device.lock().read(cc_index) < 0.5);
        }
    }
}
