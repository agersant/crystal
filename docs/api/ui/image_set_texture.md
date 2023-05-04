---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Image:set_texture

Sets or clear the texture to draw.

## Usage

```lua
image:set_texture(texture, adopt_size)
```

### Arguments

| Name         | Type                                                     | Description                                                                                                                                                                           |
| :----------- | :------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `texture`    | `nil` \| [love.Texture](https://love2d.org/wiki/Texture) | Texture to draw, or `nil` to draw a solid color.                                                                                                                                      |
| `adopt_size` | `boolean`                                                | If true, the image element will be [resized](image_set_image_size) to match the texture. Adopting the size of a `nil` texture resizes the image to 1x1. Defaults to false if omitted. |

## Examples

```lua
local image = crystal.Image:new();

image:set_texture(crystal.assets.get("assets/ui/menu_background.png"), true);
print(image:image_size()); -- Prints the size of `menu_background.png`

image:set_texture(crystal.assets.get("assets/ui/cursor.png"), false);
print(image:image_size()); -- Still prints the size of `menu_background.png`
```
