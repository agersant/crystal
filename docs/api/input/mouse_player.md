---
parent: crystal.input
grand_parent: API Reference
nav_order: 1
---

# crystal.input.mouse_player

Returns the player index of the player using the mouse. This is player 1 by default, and can be changed by calling [assign_mouse](assign_mouse).

## Usage

```lua
crystal.input.mouse_player()
```

### Returns

| Name           | Type     | Description                                                        |
| :------------- | :------- | :----------------------------------------------------------------- |
| `player_index` | `number` | Numeric identifier representing the player who is using the mouse. |

## Examples

```lua
crystal.input.assign_mouse(2);
assert(crystal.input.mouse_player() == 2);
```
