---
parent: crystal.input
grand_parent: API Reference
nav_order: 1
---

# crystal.input.player

Returns the [InputPlayer](input_player) representing a physical player.

## Usage

```lua
crystal.input.player(player_index)
```

### Arguments

| Name           | Type     | Description                  |
| :------------- | :------- | :--------------------------- |
| `player_index` | `number` | Number identifying a player. |

### Returns

| Name           | Type                        | Description                                                         |
| :------------- | :-------------------------- | :------------------------------------------------------------------ |
| `input_player` | [InputPlayer](input_player) | Object handling keybinds and input events for the specified player. |

## Examples

```lua
local player_1 = crystal.input.player(1);
player_1:set_bindings({
  space = { "jump" },
  z = { "dodge_roll" },
});
```
