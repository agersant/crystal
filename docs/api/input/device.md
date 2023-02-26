---
parent: crystal.input
grand_parent: API Reference
nav_order: 1
---

# crystal.input.device

Returns the [InputDevice](input_device) assigned to a player.

## Usage

```lua
crystal.input.device(player_index)
```

### Arguments

| Name           | Type     | Description                  |
| :------------- | :------- | :--------------------------- |
| `player_index` | `number` | Number identifying a player. |

### Returns

| Name           | Type                        | Description                                                                 |
| :------------- | :-------------------------- | :-------------------------------------------------------------------------- |
| `input_device` | [InputDevice](input_device) | Virtual device handling keybinds and input events for the specified player. |

## Examples

```lua
local player_1 = crystal.input.device(1);
player_1:set_bindings({
	space = { "jump" },
	z = { "dodge_roll" },
});
```
