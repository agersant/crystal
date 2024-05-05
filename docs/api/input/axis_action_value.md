---
parent: crystal.input
grand_parent: API Reference
nav_order: 1
---

# crystal.input.axis_action_value

Returns the value of a gamepad axis associated with a specific action.

If the player's [input method](input_player_input_method) is not `gamepad`, this function returns 0.

If no axis is mapped to the requested action, this function returns 0.

## Usage

```lua
crystal.input.axis_action_value(player_index, axis_action)
```

### Arguments

| Name           | Type     | Description                  |
| :------------- | :------- | :--------------------------- |
| `player_index` | `number` | Number identifying a player. |
| `axis_action`  | `string` | Action to check axis for.    |

### Returns

| Name    | Type     | Description                          |
| :------ | :------- | :----------------------------------- |
| `value` | `number` | Current position of the gamepad axis |

## Examples

```lua
crystal.input.assign_gamepad(1, 1); -- Assigns gamepad 1 to player 1
crystal.input.set_bindings(1, { leftx = { "move_x" } }); -- Moving the left stick horizontally drives an axis (arbitrarily) named "move_x"
print(crystal.input.axis_action_value("move_x")); -- Prints horizontal position of the left stick on gamepad 1
```
