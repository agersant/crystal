---
parent: crystal.window
grand_parent: API Reference
nav_order: 1
---

# crystal.window.set_safe_area

Sets how much of the game can be cropped to preserve pixel-perfect scaling. This value is only used in combination with the `crop_or_squish` [scaling_mode](set_scaling_mode).

For example, setting the safe area to `0.95` allows up to 2.5% of the screen to get cropped on each side.

The default value is `0.9`.

## Usage

```lua
crystal.window.set_safe_area(safe_area)
```

### Arguments

| Name            | Type     | Description                                               |
| :-------------- | :------- | :-------------------------------------------------------- |
| `set_safe_area` | `number` | Proportion of the game viewport that must remain visible. |

## Examples

```lua
crystal.window.set_safe_area(0.95);
```
