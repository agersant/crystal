---
parent: crystal.input
grand_parent: API Reference
nav_order: 1
---

# crystal.input.map_axis_to_actions

Map analog positions on gamepad sticks (axis) to binary actions.

When an action is bound to a [gamepad axis](https://love2d.org/wiki/GamepadAxis), it never emits `"+action"` or `"-action"` events like actions using buttons do. Its value can only be queried via [InputPlayer:axis_action_value](input_player:axis_action_value).

This function allows axis to emit regular action events when they are pushed in specific positions. The most common use case for this is to map the X/Y axis of a stick to emit up/down/left/right action events.

## Usage

```lua
crystal.input.map_axis_to_actions(configuration)
```

### Arguments

| Name            | Type    | Description                                                      |
| :-------------- | :------ | :--------------------------------------------------------------- |
| `configuration` | `table` | Table describing what actions should be emitted by gamepad axis. |

Each key in the `configuration` table is an action bound to a [gamepad axis](https://love2d.org/wiki/GamepadAxis).

The value associated with each axis action is a table where each key is a (regular) action that can be emitted by this axis. The value associated with each of these actions is a table listing the range of [axis values](https://love2d.org/wiki/Joystick:getGamepadAxis) where the input is considered pressed / released.

Schema for the configuration table:

```lua
{
  [input_action] = {
    [action] = { pressed_range = { min, max }, released_range = { min, max } }
    ...
  },
  ...
}
```

## Examples

```lua
crystal.input.player(1):set_bindings({
  --[[ Map each dpad button to two actions:
    - `move_*` to move the player character
    - `ui_*` to navigate in a menu
  ]]
  dpup = { "move_up", "ui_up" },
  dpdown = { "move_down", "ui_down" },
  dpleft = { "move_left", "ui_left" },
  dpright = { "move_right", "ui_right" },
  -- Map left stick to move and ui actions on each axis
  leftx = { "move_x", "ui_x" },
  lefty = { "move_y", "ui_y" },
});

-- Map flicks of ui_x and ui_y to corresponding discrete actions
crystal.input.map_axis_to_actions({
  ui_x = {
    ui_left = { pressed_range = { -1.0, -0.9 }, released_range = { -0.2, 1.0 } },
    ui_right = { pressed_range = { 0.9, 1.0 }, released_range = { -1.0, 0.2 } },
  },
  ui_y = {
    ui_up = { pressed_range = { -1.0, -0.9 }, released_range = { -0.2, 1.0 } },
    ui_down = { pressed_range = { 0.9, 1.0 }, released_range = { -1.0, 0.2 } },
  },
});
```
