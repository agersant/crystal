---
parent: crystal.window
grand_parent: API Reference
nav_order: 1
---

# crystal.window.set_native_height

Sets the game's native-height (in pixels) from which it can be upscaled. This is the height of your game viewport when drawn at zoom 1x.

Note that there is no `set_native_width` function. The viewport width is determined according to the window aspect ratio and the [aspect ratio limits](set_aspect_ratio_limits).

The default native height is 240 pixels.

## Usage

```lua
crystal.window.set_native_height(height)
```

### Arguments

| Name     | Type     | Description              |
| :------- | :------- | :----------------------- |
| `height` | `number` | Native height in pixels. |

## Examples

```lua
crystal.window.set_native_height(480);
```
