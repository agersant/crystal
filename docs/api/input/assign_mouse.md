---
parent: crystal.input
grand_parent: API Reference
nav_order: 1
---

# crystal.input.assign_mouse

Assigns the mouse to a player. Mouse clicks will be tracked by this player's [InputPlayer](input_player).

If the mouse was already assigned to a different player, this method unassigns it from them.

In addition, this method puts all inputs for the affected player in a released state.

## Usage

```lua
crystal.input.assign_mouse(player_index)
```

### Arguments

| Name           | Type     | Description                  |
| :------------- | :------- | :--------------------------- |
| `player_index` | `number` | Number identifying a player. |

## Examples

```lua
crystal.input.assign_mouse(2);
assert(crystal.input.mouse_player() == 2);
```
