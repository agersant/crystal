---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Image:set_image_size

Sets the image size in pixels.

## Usage

```lua
image:set_image_size(width, height)
```

### Arguments

| Name     | Type     | Description       |
| :------- | :------- | :---------------- |
| `width`  | `number` | Width in pixels.  |
| `height` | `number` | Height in pixels. |

## Examples

```lua
local image = crystal.Image:new();
image:set_image_size(200, 100);
print(image:image_size()); -- Prints the 200, 100
```
