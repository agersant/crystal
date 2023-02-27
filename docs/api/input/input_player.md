---
parent: crystal.input
grand_parent: API Reference
---

# crystal.InputPlayer

Object handling keybinds and input events for a player.

## Methods

| Name                | Description                                                                         |
| :------------------ | :---------------------------------------------------------------------------------- |
| `input_method`      | Returns the input method last used by this player.                                  |
| `gamepad_id`        | Returns the gamepad assigned to this player, if any.                                |
| `bindings`          | Returns a table describing which actions are bound to which inputs for this player. |
| `is_action_active`  | Returns whether any input mapped to a specific action is currently being pressed.   |
| `action_axis_value` | Returns the value of a gamepad axis associated with a specific action.              |
| `set_bindings`      | Defines which actions are bound to which inputs for this player.                    |
| `events`            | Returns a list of actions pressed or released this frame.                           |

```lua
local player = crystal.input.player(1);
player:set_bindings({ space = { "jump" } });
love.keypressed("space", "space", false);

assert(player:is_action_active("jump"));
for _, event in ipairs(player:events()) do
  print(event); -- Prints "+jump"
end
assert(player:input_method() == "keyboard_and_mouse");

love.keyreleased("space", "space", false);
assert(not player:is_action_active("jump"));
for _, event in ipairs(player:events()) do
  print(event); -- Prints "-jump"
end
```
