---
parent: crystal.input
grand_parent: API Reference
nav_exclude: true
---

# InputPlayer:gamepad_id

Returns the gamepad assigned to this player, if any.

## Usage

```lua
input_player:gamepad_id()
```

### Returns

| Name         | Type     | Description                              |
| :----------- | :------- | :--------------------------------------- |
| `gamepad_id` | `number` | Gamepad assigned to this player, if any. |

## Examples

```lua
crystal.input.assign_gamepad(1, 5);
local player = crystal.input.player(1);
print(player:gamepad_id()); -- Prints "5"
```
