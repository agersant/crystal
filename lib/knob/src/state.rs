use anyhow::anyhow;
use core::ops::{Deref, DerefMut};
use parking_lot::Mutex;
use std::sync::{mpsc::*, Arc};
use std::time::Duration;

use crate::device::DeviceAPI;
use crate::hal::Hal;
use crate::Mode;

pub(crate) type StateHandle<H> = Arc<Mutex<State<H>>>;
pub(crate) type DeviceHandle<H> = Arc<Mutex<<H as Hal>::Device>>;

enum ConnectionTarget<H: Hal> {
    PortNumber(usize),
    Port(<H::Device as DeviceAPI>::Port),
}

enum ConnectionState<H: Hal> {
    Disconnected,
    Connecting(ConnectionTarget<H>),
    Connected(DeviceHandle<H>),
}

impl<H: Hal> Drop for ConnectionState<H> {
    fn drop(&mut self) {
        if let ConnectionState::Connected(device) = self {
            device.lock().deref_mut().drop_connection();
        }
    }
}

pub(crate) struct State<H: Hal> {
    pub hal: H,
    mode: Mode,
    _ticker: Option<Sender<()>>,
    connection_state: ConnectionState<H>,
}

impl<H: Hal> State<H> {
    pub fn new(hal: H) -> StateHandle<H> {
        let (sender, receiver) = channel::<()>();
        let state = Arc::new(Mutex::new(State {
            hal,
            mode: Mode::Absolute,
            _ticker: Some(sender),
            connection_state: ConnectionState::Disconnected,
        }));

        let poll_state = state.clone();
        std::thread::spawn(move || loop {
            {
                let mut state = poll_state.lock();
                if let Err(TryRecvError::Disconnected) = receiver.try_recv() {
                    return;
                }
                state.tick();
            }
            std::thread::sleep(Duration::from_millis(500));
        });

        state
    }

    pub fn device(&self) -> Option<&DeviceHandle<H>> {
        if let ConnectionState::Connected(device) = &self.connection_state {
            Some(device)
        } else {
            None
        }
    }

    pub fn set_mode(&mut self, mode: Mode) {
        self.mode = mode;
        if let ConnectionState::Connected(device) = &self.connection_state {
            device.lock().set_mode(mode);
        }
    }

    fn is_connected(&self) -> bool {
        if let ConnectionState::Connected(device) = &self.connection_state {
            self.hal.is_device_valid(device.lock().deref())
        } else {
            false
        }
    }

    pub fn connect(&mut self, port_number: usize) {
        self.connection_state =
            ConnectionState::Connecting(ConnectionTarget::PortNumber(port_number));
        self.tick();
    }

    pub fn disconnect(&mut self) {
        self.connection_state = ConnectionState::Disconnected;
    }

    fn tick(&mut self) {
        match &self.connection_state {
            ConnectionState::Disconnected => (),
            ConnectionState::Connecting(_) => {
                self.try_connect().ok();
            }
            ConnectionState::Connected(_) => {
                self.health_check().ok();
            }
        };
    }

    fn try_connect(&mut self) -> Result<(), anyhow::Error> {
        let port_number = match &self.connection_state {
            ConnectionState::Connecting(target) => match target {
                ConnectionTarget::PortNumber(p) => *p,
                ConnectionTarget::Port(p) => self.hal.find_port_number(p)?,
            },
            _ => return Err(anyhow!("Unexpected state")),
        };
        if let Ok(device) = self.hal.connect(port_number, self.mode) {
            self.connection_state = ConnectionState::Connected(device);
        }
        Ok(())
    }

    fn health_check(&mut self) -> Result<(), anyhow::Error> {
        let port = match &self.connection_state {
            ConnectionState::Connected(device) => device.lock().port().clone(),
            _ => return Err(anyhow!("Unexpected state")),
        };
        if !self.is_connected() {
            self.connection_state = ConnectionState::Connecting(ConnectionTarget::Port(port));
        }
        Ok(())
    }
}

#[cfg(test)]
mod tests {

    use super::*;

    #[test]
    fn fails_to_connect_without_device_list() {
        let hal = crate::hal::MockHardware { devices: None };
        let state = State::new(hal);
        state.lock().connect(0);
        assert!(!state.lock().is_connected());
    }

    #[test]
    fn fails_to_connect_with_empty_device_list() {
        let hal = crate::hal::MockHardware {
            devices: Some(vec![]),
        };
        let state = State::new(hal);
        state.lock().connect(0);
        assert!(!state.lock().is_connected());
    }

    #[test]
    fn keeps_track_of_connection() {
        let hal = crate::hal::MockHardware {
            devices: Some(vec!["device 1".to_owned()]),
        };
        let state = State::new(hal);
        assert!(!state.lock().is_connected());
        state.lock().connect(0);
        assert!(state.lock().is_connected());
        state.lock().disconnect();
        assert!(!state.lock().is_connected());
    }

    #[test]
    fn current_device_removal_causes_disconnect() {
        let hal = crate::hal::MockHardware {
            devices: Some(vec!["device 1".to_owned(), "device 2".to_owned()]),
        };
        let state = State::new(hal);
        state.lock().connect(0);
        assert!(state.lock().is_connected());
        state.lock().hal = crate::hal::MockHardware {
            devices: Some(vec!["device 2".to_owned()]),
        };
        assert!(!state.lock().is_connected());
    }

    #[test]
    fn other_device_removal_does_not_cause_disconnect() {
        let hal = crate::hal::MockHardware {
            devices: Some(vec!["device 1".to_owned(), "device 2".to_owned()]),
        };
        let state = State::new(hal);
        state.lock().connect(1);
        assert!(state.lock().is_connected());
        state.lock().hal = crate::hal::MockHardware {
            devices: Some(vec!["device 2".to_owned()]),
        };
        assert!(state.lock().is_connected());
    }

    #[test]
    fn reconnects_on_different_port_number() {
        let hal = crate::hal::MockHardware {
            devices: Some(vec!["device 1".to_owned(), "device 2".to_owned()]),
        };
        let state = State::new(hal);
        state.lock().connect(1);
        assert!(state.lock().is_connected());
        state.lock().hal = crate::hal::MockHardware {
            devices: Some(vec![]),
        };
        assert!(!state.lock().is_connected());
        state.lock().hal = crate::hal::MockHardware {
            devices: Some(vec!["device 2".to_owned()]),
        };
        assert!(state.lock().is_connected());
    }

    #[test]
    fn mode_change_does_not_cause_disconnect() {
        let hal = crate::hal::MockHardware {
            devices: Some(vec!["device 1".to_owned(), "device 2".to_owned()]),
        };
        let state = State::new(hal);
        state.lock().connect(0);
        state.lock().set_mode(Mode::Absolute);
        assert!(state.lock().is_connected());
        state.lock().set_mode(Mode::RelativeArturia1);
        assert!(state.lock().is_connected());
    }

    #[test]
    fn mode_change_applies_to_current_device() {
        let hal = crate::hal::MockHardware {
            devices: Some(vec!["device 1".to_owned(), "device 2".to_owned()]),
        };
        let state = State::new(hal);
        state.lock().connect(0);
        state.lock().set_mode(Mode::RelativeArturia1);
        assert_eq!(
            state.lock().device().unwrap().lock().mode(),
            Mode::RelativeArturia1
        );
    }

    #[test]
    fn mode_change_applies_to_future_device() {
        let hal = crate::hal::MockHardware {
            devices: Some(vec!["device 1".to_owned(), "device 2".to_owned()]),
        };
        let state = State::new(hal);
        state.lock().set_mode(Mode::RelativeArturia1);
        state.lock().connect(0);
        assert_eq!(
            state.lock().device().unwrap().lock().mode(),
            Mode::RelativeArturia1
        );
    }
}
