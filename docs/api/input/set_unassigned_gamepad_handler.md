---
parent: crystal.input
grand_parent: API Reference
nav_order: 1
---

# crystal.input.set_unassigned_gamepad_handler

Defines a callback function which runs when a button is pressed on an unassigned gamepad.

If you do not call this function to setup your own handler, the default handler will [assign](assign_gamepad) the new gamepad to player 1. This is sufficient for single player games. In multiplayer games, you should implement logic to decide which player the new gamepad should be assigned to and call [assign_gamepad](assign_gamepad), or ignore the input entirely.

## Usage

```lua
crystal.input.set_unassigned_gamepad_handler(handler)
```

### Arguments

| Name      | Type                                           | Description                                                         |
| :-------- | :--------------------------------------------- | :------------------------------------------------------------------ |
| `handler` | `function(gamepad_id: number, button: string)` | Function to call when a button is pressed on an unassigned gamepad. |

The `gamepad_id` received by the handler function is from LOVE's [Joystick:getID](https://love2d.org/wiki/Joystick:getID).

The `button` received by the handler function is similar to a [love.GamepadButton](https://love2d.org/wiki/GamepadButton). The difference is that face-buttons in this handler are represented by `pad_a`, `pad_b`, `pad_x`, `pad_y` instead of `a`, `b`, `x`, `y`.

## Examples

This example assigns gamepads sequentially when players press `start` in a 4 player game.

```lua
crystal.input.set_unassigned_gamepad_handler(function(gamepad_id, button)
  if button ~= "start" then
    return;
  end
  for i = 1, 4 do
    if crystal.input.player(i):input_method() == nil then
      crystal.input.assign_gamepad(i, gamepad_id);
    end
  end
end);
```
