---
parent: crystal.input
grand_parent: API Reference
nav_order: 1
---

# crystal.input.is_action_down

Returns whether any input mapped to a specific action is currently being pressed.

## Usage

```lua
crystal.input.is_action_down(player_index, action)
```

### Arguments

| Name           | Type     | Description                          |
| :------------- | :------- | :----------------------------------- |
| `player_index` | `number` | Number identifying a player.         |
| `action`       | `string` | Action whose current state to check. |

### Returns

| Name   | Type      | Description                                                               |
| :----- | :-------- | :------------------------------------------------------------------------ |
| `down` | `boolean` | True if an input mapped to this action is being pressed, false otherwise. |

## Examples

```lua
crystal.input.set_bindings(1, { space = { "jump" } });
print(crystal.input.is_action_active("jump")); -- Prints "false"
```
