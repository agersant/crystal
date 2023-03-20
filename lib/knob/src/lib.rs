use mlua::prelude::*;
use std::str::FromStr;
use strum::{EnumIter, EnumString};

use device::DeviceAPI;
use hal::Hal;
use state::StateHandle;

mod device;
mod hal;
mod state;

// https://www.yamahasynth.com/ask-a-question/relative-mode-for-control-knobs#reply-102919
#[derive(Clone, Copy, Debug, EnumIter, EnumString, PartialEq, Eq)]
#[strum(ascii_case_insensitive)]
enum Mode {
    Absolute,
    RelativeAkai,
    RelativeArturia1,
    RelativeArturia2,
    RelativeArturia3,
}

fn connect<T: Hal>(state: StateHandle<T>, port_number: usize) {
    let mut state = state.lock();
    state.connect(port_number);
}

fn list_devices<T: Hal>(state: StateHandle<T>) -> Vec<String> {
    let state = state.lock();
    state.hal.list_devices().unwrap_or_default()
}

fn get_current_device<T: Hal>(state: StateHandle<T>) -> Option<String> {
    let state = state.lock();
    state.device().map(|d| state.hal.get_device_name(&d.lock()))
}

fn set_mode<T: Hal>(state: StateHandle<T>, mode: Mode) {
    let mut state = state.lock();
    state.set_mode(mode);
}

fn read_knob<T: Hal>(state: StateHandle<T>, cc_index: u8) -> f32 {
    let state = state.lock();
    state
        .device()
        .map(|d| d.lock().read(cc_index))
        .unwrap_or(-1.0)
}

fn write_knob<T: Hal>(state: StateHandle<T>, cc_index: u8, value: f32) {
    let state = state.lock();
    if let Some(device) = state.device() {
        device.lock().write(cc_index, value);
    }
}

fn disconnect<T: Hal>(state: StateHandle<T>) {
    let mut state = state.lock();
    state.disconnect();
}

fn quit<T: Hal>(state: StateHandle<T>) {
    let mut state = state.lock();
    state.quit();
}

impl<'lua> FromLua<'lua> for Mode {
    fn from_lua(lua_value: LuaValue<'lua>, _lua: &'lua Lua) -> LuaResult<Self> {
        match lua_value {
            LuaValue::String(ref s) => Mode::from_str(s.to_string_lossy().as_ref()).map_err(|e| {
                LuaError::FromLuaConversionError {
                    from: lua_value.type_name(),
                    to: "Mode",
                    message: Some(e.to_string()),
                }
            }),
            _ => Err(LuaError::FromLuaConversionError {
                from: lua_value.type_name(),
                to: "Mode",
                message: None,
            }),
        }
    }
}

#[mlua::lua_module]
fn knob(lua: &Lua) -> LuaResult<LuaTable> {
    #[cfg(not(test))]
    let state: state::StateHandle<hal::MidiHardware> = state::State::new(hal::MidiHardware {});

    #[cfg(test)]
    let state: state::StateHandle<hal::SampleHardware> = state::State::new(hal::SampleHardware {});

    let exports = lua.create_table()?;

    exports.set(
        "connect",
        lua.create_function({
            let state = state.clone();
            move |_, port_number: usize| {
                connect(state.clone(), port_number);
                Ok(())
            }
        })?,
    )?;

    exports.set(
        "disconnect",
        lua.create_function({
            let state = state.clone();
            move |_, _: ()| {
                disconnect(state.clone());
                Ok(())
            }
        })?,
    )?;

    exports.set(
        "current_device",
        lua.create_function({
            let state = state.clone();
            move |_, _: ()| Ok(get_current_device(state.clone()))
        })?,
    )?;

    exports.set(
        "list_devices",
        lua.create_function({
            let state = state.clone();
            move |_, _: ()| Ok(list_devices(state.clone()))
        })?,
    )?;

    exports.set(
        "read",
        lua.create_function({
            let state = state.clone();
            move |_, cc_index: u8| Ok(read_knob(state.clone(), cc_index))
        })?,
    )?;

    exports.set(
        "set_mode",
        lua.create_function({
            let state = state.clone();
            move |_, mode: Mode| {
                set_mode(state.clone(), mode);
                Ok(())
            }
        })?,
    )?;

    exports.set(
        "write",
        lua.create_function({
            let state = state.clone();
            move |_, (cc_index, value): (u8, f32)| {
                write_knob(state.clone(), cc_index, value);
                Ok(())
            }
        })?,
    )?;

    exports.set(
        "quit",
        lua.create_function({
            move |_, _: ()| {
                quit(state.clone());
                Ok(())
            }
        })?,
    )?;

    Ok(exports)
}
