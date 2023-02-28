---
parent: crystal.input
grand_parent: API Reference
nav_exclude: true
---

# InputPlayer:axis_action_value

Returns the value of a gamepad axis associated with a specific action.

If the player's [input method](input_player_input_method) is not `gamepad`, this function returns 0.

If no axis is mapped to the requested action, this function returns 0.

## Usage

```lua
input_player:axis_action_value(axis_action)
```

### Arguments

| Name          | Type     | Description               |
| :------------ | :------- | :------------------------ |
| `axis_action` | `string` | Action to check axis for. |

### Returns

| Name    | Type     | Description                          |
| :------ | :------- | :----------------------------------- |
| `value` | `number` | Current position of the gamepad axis |

## Examples

```lua
local player = crystal.input.player(1);
crystal.input.assign_gamepad(1, 1);
player:set_bindings({ leftx = { "move_x" } });
print(player:axis_action_value("move_x")); -- Prints x position of left stick on gamepad 1
```
