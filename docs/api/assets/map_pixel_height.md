---
parent: crystal.assets
grand_parent: API Reference
nav_exclude: true
---

# Map:pixel_height

Returns the height of the map in pixels.

## Usage

```lua
map:pixel_height()
```

### Returns

| Name     | Type     | Description       |
| :------- | :------- | :---------------- |
| `height` | `number` | Height in pixels. |

## Examples

```lua
local map = crystal.assets.get("assets/maps/forest.lua");
local area = map:pixel_width() * map:pixel_height();
print(area);
```
