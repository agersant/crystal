---
parent: crystal.assets
grand_parent: API Reference
nav_exclude: true
---

# Map:tilesets

Returns all [tilesets](tileset) used by this map.

## Usage

```lua
map:tilesets()
```

### Returns

| Name       | Type    | Description       |
| :--------- | :------ | :---------------- |
| `tilesets` | `table` | List of tilesets. |

## Examples

```lua
local map = crystal.assets.get("assets/maps/dungeon.lua");
for _, tileset in ipairs(map:tilesets()) do
  print(tileset:image());
end
```
