---
parent: crystal.assets
grand_parent: API Reference
nav_exclude: true
---

# Tileset:num_tiles()

Returns the number of tiles in this tileset.

## Usage

```lua
tileset:num_tiles()
```

### Returns

| Name    | Type     | Description      |
| :------ | :------- | :--------------- |
| `count` | `number` | Number of tiles. |

## Examples

```lua
local map = crystal.assets.get("assets/maps/dungeon.lua");
for _, tileset in ipairs(map:tilesets()) do
  print(tileset:num_tiles());
end
```
