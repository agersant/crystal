---
parent: crystal.input
grand_parent: API Reference
nav_order: 1
---

# crystal.input.assign_gamepad

Assigns a gamepad to a player. Gamepad button presses from the assigned gamepad will be tracked by this player's [InputPlayer](input_player).

If the gamepad was already assigned to a different player, this method unassigns it from them.

In addition:

- This method puts all inputs for the affected player in a released state.
- The player's [input method](input_player_input_method) is set to `gamepad`.

## Usage

```lua
crystal.input.assign_gamepad(player_index, gamepad_id)
```

### Arguments

| Name           | Type     | Description                                                                                               |
| :------------- | :------- | :-------------------------------------------------------------------------------------------------------- |
| `player_index` | `number` | Number identifying a player.                                                                              |
| `gamepad_id`   | `number` | Number identifying a gamepad. These are [Joystick IDs](https://love2d.org/wiki/Joystick:getID) from LOVE. |

## Examples

```lua
local player_index = 1;
local gamepad_id = love.input.getJoysticks()[1]:getID();
crystal.input.assign_gamepad(player_index, gamepad_id);
```
