use anyhow::{anyhow, Context};
use midir::{MidiInput, MidiInputConnection, MidiInputPort};
use parking_lot::Mutex;
use std::sync::{mpsc::*, Arc};

use crate::device::{Device, DeviceAPI};
use crate::Mode;

static MIDI_CLIENT_NAME: &str = "crystal-knob-client-input";
static MIDI_PORT_NAME: &str = "crystal-knob-input-port";
static UNKNOWN_DEVICE_NAME: &str = "Unknown MIDI Device";

pub(crate) trait Hal: Send + 'static {
    type Device: DeviceAPI;

    fn connect(
        &self,
        port_number: usize,
        mode: Mode,
    ) -> Result<Arc<Mutex<Self::Device>>, anyhow::Error>;

    fn list_devices(&self) -> Result<Vec<String>, anyhow::Error>;

    fn get_device_name(&self, device: &Self::Device) -> String;

    fn is_device_valid(&self, device: &Self::Device) -> bool;

    fn find_port_number(
        &self,
        port: &<Self::Device as DeviceAPI>::Port,
    ) -> Result<usize, anyhow::Error>;
}

pub(crate) struct MidiHardware {}

impl MidiHardware {
    fn get_midi_input() -> Result<MidiInput, anyhow::Error> {
        MidiInput::new(MIDI_CLIENT_NAME).context("Failed to create MIDI input")
    }
}

impl Hal for MidiHardware {
    type Device = Device<MidiInputConnection<()>, MidiInputPort>;

    fn connect(
        &self,
        port_number: usize,
        mode: Mode,
    ) -> Result<Arc<Mutex<Self::Device>>, anyhow::Error> {
        let midi_input = Self::get_midi_input()?;
        let ports = midi_input.ports();
        if ports.is_empty() {
            return Err(anyhow!("No MIDI devices detected"));
        }

        if port_number >= ports.len() {
            return Err(anyhow!("No MIDI device exists on port {}", port_number));
        }

        let port = &ports[port_number];
        let device_name = midi_input
            .port_name(port)
            .unwrap_or_else(|_| UNKNOWN_DEVICE_NAME.to_owned());

        let (sender, receiver) = channel::<Vec<u8>>();
        let connection = midi_input
            .connect(
                port,
                MIDI_PORT_NAME,
                move |_, message, _| sender.send(message.to_vec()).unwrap(),
                (),
            )
            // TODO: https://github.com/Boddlnagg/midir/issues/55
            .map_err(|e| midir::ConnectError::new(e.kind(), ()))?;

        let device = Device::new(device_name, mode, port.clone(), connection, receiver);

        Ok(device)
    }

    fn list_devices(&self) -> Result<Vec<String>, anyhow::Error> {
        let midi_input = Self::get_midi_input()?;
        let devices = midi_input
            .ports()
            .iter()
            .map(|port| {
                midi_input
                    .port_name(port)
                    .unwrap_or_else(|_| UNKNOWN_DEVICE_NAME.to_owned())
            })
            .collect();
        Ok(devices)
    }

    fn get_device_name(&self, device: &Self::Device) -> String {
        Self::get_midi_input()
            .and_then(|m| m.port_name(device.port()).map_err(|e| e.into()))
            .unwrap_or_else(|_| UNKNOWN_DEVICE_NAME.to_owned())
    }

    fn is_device_valid(&self, device: &Self::Device) -> bool {
        // TODO https://github.com/Boddlnagg/midir/issues/35
        // This code isn't reliable when multiple devices have the same name
        let device_name = Self::get_midi_input()
            .and_then(|m| m.port_name(device.port()).map_err(|e| e.into()))
            .unwrap_or_else(|_| UNKNOWN_DEVICE_NAME.to_owned());
        let devices = self.list_devices().unwrap_or_default();
        devices.iter().any(|name| *name == device_name)
    }

    fn find_port_number(
        &self,
        port: &<Self::Device as DeviceAPI>::Port,
    ) -> Result<usize, anyhow::Error> {
        // TODO https://github.com/Boddlnagg/midir/issues/35
        // This code isn't reliable when multiple devices have the same name
        let device_name = Self::get_midi_input()
            .and_then(|m| m.port_name(port).map_err(|e| e.into()))
            .unwrap_or_else(|_| UNKNOWN_DEVICE_NAME.to_owned());
        let devices = self.list_devices().unwrap_or_default();
        devices
            .iter()
            .position(|name| *name == device_name)
            .ok_or_else(|| anyhow!("device not found"))
    }
}

#[cfg(test)]
pub(crate) struct SampleHardware {}

#[cfg(test)]
impl Hal for SampleHardware {
    type Device = Device<(), ()>;

    fn connect(
        &self,
        _port_number: usize,
        mode: Mode,
    ) -> Result<Arc<Mutex<Self::Device>>, anyhow::Error> {
        let (_sender, receiver) = std::sync::mpsc::channel();
        let device = Device::new("sample_device", mode, (), (), receiver);
        Ok(device)
    }

    fn list_devices(&self) -> Result<Vec<String>, anyhow::Error> {
        Ok(vec!["sample_device".to_owned()])
    }

    fn get_device_name(&self, _device: &Self::Device) -> String {
        "sample_device".to_owned()
    }

    fn is_device_valid(&self, _device: &Self::Device) -> bool {
        true
    }

    fn find_port_number(
        &self,
        _port: &<Self::Device as DeviceAPI>::Port,
    ) -> Result<usize, anyhow::Error> {
        Ok(0)
    }
}

#[cfg(test)]
pub(crate) struct MockHardware {
    pub devices: Option<Vec<String>>,
}

#[cfg(test)]
impl Hal for MockHardware {
    type Device = Device<(), String>;

    fn connect(
        &self,
        port_number: usize,
        mode: Mode,
    ) -> Result<Arc<Mutex<Self::Device>>, anyhow::Error> {
        let devices = self.list_devices().unwrap_or_default();
        if port_number >= devices.len() {
            return Err(anyhow!("No device exists on port {}", port_number));
        }
        let device_name = self.devices.as_ref().unwrap()[port_number].as_str();
        let port = device_name.to_owned();
        let (_sender, receiver) = std::sync::mpsc::channel();
        let device = Device::new(device_name, mode, port, (), receiver);
        Ok(device)
    }

    fn list_devices(&self) -> Result<Vec<String>, anyhow::Error> {
        match &self.devices {
            None => Err(anyhow!("no device list")),
            Some(d) => Ok(d.clone()),
        }
    }

    fn get_device_name(&self, device: &Self::Device) -> String {
        device.port().clone()
    }

    fn is_device_valid(&self, device: &Self::Device) -> bool {
        self.list_devices()
            .unwrap_or_default()
            .contains(device.port())
    }

    fn find_port_number(
        &self,
        port: &<Self::Device as DeviceAPI>::Port,
    ) -> Result<usize, anyhow::Error> {
        self.list_devices()
            .unwrap_or_default()
            .iter()
            .position(|n| n == port)
            .ok_or_else(|| anyhow!("device not found"))
    }
}
