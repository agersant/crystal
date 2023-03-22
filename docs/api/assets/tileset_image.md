---
parent: crystal.assets
grand_parent: API Reference
nav_exclude: true
---

# Tileset:image

Returns the [love.Image](https://love2d.org/wiki/Image) used by this tileset.

## Usage

```lua
tileset:image()
```

### Returns

| Name    | Type                                        | Description                 |
| :------ | :------------------------------------------ | :-------------------------- |
| `image` | [love.Image](https://love2d.org/wiki/Image) | Image used by this tileset. |

## Examples

```lua
local map = crystal.assets.get("assets/maps/dungeon.lua");
for _, tileset in ipairs(map:tilesets()) do
  print(tileset:image());
end
```
