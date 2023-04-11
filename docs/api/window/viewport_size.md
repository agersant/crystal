---
parent: crystal.window
grand_parent: API Reference
---

# crystal.window.viewport_size

Returns the width and height at which the game is being rendered (before upscaling).

{: .note}
The viewport height is always equal to the game's [native_height](set_native_height).

## Usage

```lua
crystal.window.viewport_size()
```

### Returns

| Name     | Type     | Description                       |
| :------- | :------- | :-------------------------------- |
| `width`  | `number` | Width of the viewport in pixels.  |
| `height` | `number` | Height of the viewport in pixels. |

## Examples

```lua
crystal.window.set_native_height(240);
crystal.window.set_aspect_ratio_limits(3/2, 3/2);
print(crystal.window.viewport_size()); -- Prints 360, 240
```
