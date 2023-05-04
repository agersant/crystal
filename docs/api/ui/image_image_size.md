---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Image:image_size

Returns the image size in pixels.

## Usage

```lua
image:image_size()
```

### Returns

| Name     | Type     | Description       |
| :------- | :------- | :---------------- |
| `width`  | `number` | Width in pixels.  |
| `height` | `number` | Height in pixels. |

## Examples

```lua
local image = crystal.Image:new(crystal.assets.get("assets/ui/menu_background.png"));
print(image:image_size()); -- Prints the size of `menu_background.png`
```
