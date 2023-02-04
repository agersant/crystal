use lazy_static::lazy_static;
use mlua::prelude::*;
use std::str::FromStr;

mod io;

#[cfg(not(test))]
lazy_static! {
    pub static ref HARDWARE_STATE: io::state::StateHandle<io::hal::MidiHardware> =
        io::state::State::new(io::hal::MidiHardware {});
}

#[cfg(test)]
lazy_static! {
    pub static ref HARDWARE_STATE: io::state::StateHandle<io::hal::SampleHardware> =
        io::state::State::new(io::hal::SampleHardware {});
}

impl<'lua> FromLua<'lua> for io::Mode {
    fn from_lua(lua_value: LuaValue<'lua>, _lua: &'lua Lua) -> LuaResult<Self> {
        match lua_value {
            LuaValue::String(ref s) => {
                io::Mode::from_str(s.to_string_lossy().as_ref()).map_err(|e| {
                    LuaError::FromLuaConversionError {
                        from: lua_value.type_name(),
                        to: "io::Mode",
                        message: Some(e.to_string()),
                    }
                })
            }
            _ => Err(LuaError::FromLuaConversionError {
                from: lua_value.type_name(),
                to: "io::Mode",
                message: None,
            }),
        }
    }
}

#[mlua::lua_module]
fn knob(lua: &Lua) -> LuaResult<LuaTable> {
    let exports = lua.create_table()?;

    exports.set(
        "connectToDevice",
        lua.create_function(|_, port_number: usize| {
            io::connect(HARDWARE_STATE.clone(), port_number);
            Ok(())
        })?,
    )?;

    exports.set(
        "disconnectFromDevice",
        lua.create_function(|_, _: ()| {
            io::disconnect(HARDWARE_STATE.clone());
            Ok(())
        })?,
    )?;

    exports.set(
        "getCurrentDevice",
        lua.create_function(|_, _: ()| Ok(io::get_current_device(HARDWARE_STATE.clone())))?,
    )?;

    exports.set(
        "listDevices",
        lua.create_function(|_, _: ()| Ok(io::list_devices(HARDWARE_STATE.clone())))?,
    )?;

    exports.set(
        "readKnob",
        lua.create_function(|_, cc_index: u8| Ok(io::read_knob(HARDWARE_STATE.clone(), cc_index)))?,
    )?;

    exports.set(
        "setMode",
        lua.create_function(|_, mode: io::Mode| {
            io::set_mode(HARDWARE_STATE.clone(), mode);
            Ok(())
        })?,
    )?;

    exports.set(
        "writeKnob",
        lua.create_function(|_, (cc_index, value): (u8, f32)| {
            io::write_knob(HARDWARE_STATE.clone(), cc_index, value);
            Ok(())
        })?,
    )?;

    Ok(exports)
}
