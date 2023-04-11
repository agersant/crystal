---
parent: crystal.window
grand_parent: API Reference
nav_order: 1
---

# crystal.window.set_scaling_mode

Sets how the game draws at resolutions larger than its native size.

The default scaling mode is `"crop_or_squish"`.

## Usage

```lua
crystal.window.set_scaling_mode(mode)
```

### Arguments

| Name   | Type                        | Description          |
| :----- | :-------------------------- | :------------------- |
| `mode` | [ScalingMode](scaling_mode) | Scaling mode to use. |

## Examples

```lua
crystal.window.set_scaling_mode("none");
```

```lua
crystal.window.set_scaling_mode("pixel_perfect");
```

```lua
crystal.window.set_scaling_mode("crop_or_squish");
```
