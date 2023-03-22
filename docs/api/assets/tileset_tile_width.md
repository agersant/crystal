---
parent: crystal.assets
grand_parent: API Reference
nav_exclude: true
---

# Tileset:tile_width()

Returns the width in pixels of a single tile.

## Usage

```lua
tileset:tile_width()
```

### Returns

| Name    | Type     | Description           |
| :------ | :------- | :-------------------- |
| `width` | `number` | Tile width in pixels. |

## Examples

```lua
local map = crystal.assets.get("assets/maps/dungeon.lua");
for _, tileset in ipairs(map:tilesets()) do
  print(tileset:tile_height());
  print(tileset:tile_width());
end
```
