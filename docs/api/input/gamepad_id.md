---
parent: crystal.input
grand_parent: API Reference
nav_exclude: true
---

# crystal.input.gamepad_id

Returns the gamepad assigned to the specified player, if any.

## Usage

```lua
crystal.input.gamepad_id(player_index)
```

### Arguments

| Name           | Type     | Description                  |
| :------------- | :------- | :--------------------------- |
| `player_index` | `number` | Number identifying a player. |

### Returns

| Name         | Type     | Description                              |
| :----------- | :------- | :--------------------------------------- |
| `gamepad_id` | `number` | Gamepad assigned to this player, if any. |

## Examples

```lua
crystal.input.assign_gamepad(1, 5);
print(crystal.input.gamepad_id(1)); -- Prints "5"
```
