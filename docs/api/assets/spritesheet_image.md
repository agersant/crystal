---
parent: crystal.assets
grand_parent: API Reference
nav_exclude: true
---

# Spritesheet:image

Returns the `love.Image` containing the texture data for this spritesheet.

## Usage

```lua
spritesheet:image()
```

### Returns

| Name    | Type                                        | Description                                             |
| :------ | :------------------------------------------ | :------------------------------------------------------ |
| `image` | [love.Image](https://love2d.org/wiki/Image) | Image containing the texture data for this spritesheet. |

## Examples

```lua
local spritesheet = crystal.assets.get("assets/sprites/hero.lua");
print(spritesheet:image():getDimensions());
```
