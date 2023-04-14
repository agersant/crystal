---
parent: crystal.window
grand_parent: API Reference
nav_order: 1
---

# crystal.window.set_aspect_ratio_limits

Sets the narrowest and widest aspect ratios the game supports. These limits are used to determine the viewport width.

The default limits are 4:3 and 21:9.

## Usage

```lua
crystal.window.set_aspect_ratio_limits(min_aspect_ratio, max_aspect_ratio)
```

### Arguments

| Name               | Type     | Description                     |
| :----------------- | :------- | :------------------------------ |
| `min_aspect_ratio` | `number` | Minimum supported aspect ratio. |
| `max_aspect_ratio` | `number` | Maximum supported aspect ratio. |

## Examples

```lua
crystal.window.set_aspect_ratio_limits(4/3, 21/9);
```
