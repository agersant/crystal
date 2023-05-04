---
parent: crystal.ui
grand_parent: API Reference
nav_order: 2
---

# crystal.Image

A [UI element](ui_element) which draws a texture or a solid color.

## Constructor

```lua
crystal.Image:new(texture)
```

The `texture` argument can be `nil` or a [love.Texture](https://love2d.org/wiki/Texture). When constructing an `Image` with an initial texture, the image size will also be set to the size of the texture. Otherwise, it will default to 1x1 pixel.

## Methods

| Name                                   | Description                          |
| :------------------------------------- | :----------------------------------- |
| [image_size](image_image_size)         | Returns the image size in pixels.    |
| [set_image_size](image_set_image_size) | Sets the image size in pixels.       |
| [set_texture](image_set_texture)       | Sets or clear the texture to draw.   |
| [texture](image_texture)               | Returns the texture to draw, if any. |

## Examples

```lua
local image = crystal.Image:new(crystal.assets.get("assets/ui/menu_background.png"));
print(image:image_size()); -- Prints the size of `menu_background.png`
```
