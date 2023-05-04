---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Image:texture

Returns the texture to draw, if any.

## Usage

```lua
image:texture()
```

### Returns

| Name      | Type                                                     | Description             |
| :-------- | :------------------------------------------------------- | :---------------------- |
| `texture` | `nil` \| [love.Texture](https://love2d.org/wiki/Texture) | Texture to draw if any. |

## Examples

```lua
local texture = crystal.assets.get("assets/ui/menu_background.png");
local image = crystal.Image:new(texture);
assert(image:texture() == texture);
```
