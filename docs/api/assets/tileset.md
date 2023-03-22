---
parent: crystal.assets
grand_parent: API Reference
nav_order: 2
---

# crystal.Tileset

Collection of tiles to build [maps](map) with.

## Constructor

You cannot construct tilesets manually. Use [crystal.assets.get](get) to load them from disk. Even better, load a [Map](map) and it will load the tileset(s) its need automatically.

## Methods

| Name                               | Description                                                                   |
| :--------------------------------- | :---------------------------------------------------------------------------- |
| [image](tileset_image)             | Returns the [love.Image](https://love2d.org/wiki/Image) used by this tileset. |
| [num_tiles](tileset_num_tiles)     | Returns the number of tiles in this tileset.                                  |
| [tile_height](tileset_tile_height) | Returns the height in pixels of a single tile.                                |
| [tile_width](tileset_tile_width)   | Returns the width in pixels of a single tile.                                 |

## Examples

```lua
local map = crystal.assets.get("assets/maps/dungeon.lua");
for _, tileset in ipairs(map:tilesets()) do
  print(tileset:image());
end
```

```lua
local tileset = crystal.assets.get("assets/tileset.lua");
print(tileset:image());
```
