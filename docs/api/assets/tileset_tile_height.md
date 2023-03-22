---
parent: crystal.assets
grand_parent: API Reference
nav_exclude: true
---

# Tileset:tile_height()

Returns the height in pixels of a single tile.

## Usage

```lua
tileset:tile_height()
```

### Returns

| Name     | Type     | Description            |
| :------- | :------- | :--------------------- |
| `height` | `number` | Tile height in pixels. |

## Examples

```lua
local map = crystal.assets.get("assets/maps/dungeon.lua");
for _, tileset in ipairs(map:tilesets()) do
  print(tileset:tile_height());
  print(tileset:tile_width());
end
```
