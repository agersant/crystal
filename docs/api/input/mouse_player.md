---
parent: crystal.input
grand_parent: API Reference
nav_order: 1
---

# crystal.input.mouse_player

Returns the [InputPlayer](input_player) with the mouse assigned to them. This is player 1 by default, and can be changed by calling [assign_mouse](assign_mouse).

## Usage

```lua
crystal.input.mouse_player()
```

### Returns

| Name           | Type                        | Description                             |
| :------------- | :-------------------------- | :-------------------------------------- |
| `input_player` | [InputPlayer](input_player) | Player with the mouse assigned to them. |

## Examples

```lua
crystal.input.assign_mouse(2);
assert(crystal.input.mouse_player() == crystal.input.player(2));
```
