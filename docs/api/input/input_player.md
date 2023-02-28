---
parent: crystal.input
grand_parent: API Reference
nav_order: 3
---

# InputPlayer

Object handling keybinds and input events for a player.

## Constructor

InputPlayers are constructed on-demand when you try to access them via [crystal.input.player](player) or [crystal.input.assign_gamepad](assign_gamepad).

## Methods

| Name                                                | Description                                                                         |
| :-------------------------------------------------- | :---------------------------------------------------------------------------------- |
| [input_method](input_player_input_method)           | Returns the input method last used by this player.                                  |
| [gamepad_id](input_player_gamepad_id)               | Returns the gamepad assigned to this player, if any.                                |
| [bindings](input_player_bindings)                   | Returns a table describing which actions are bound to which inputs for this player. |
| [is_action_active](input_player_is_action_active)   | Returns whether any input mapped to a specific action is currently being pressed.   |
| [axis_action_value](input_player_axis_action_value) | Returns the value of a gamepad axis associated with a specific action.              |
| [set_bindings](input_player_set_bindings)           | Defines which actions are bound to which inputs for this player.                    |
| [events](input_player_events)                       | Returns a list of actions pressed or released this frame.                           |

## Examples

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
