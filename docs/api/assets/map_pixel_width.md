---
parent: crystal.assets
grand_parent: API Reference
nav_exclude: true
---

# Map:pixel_width

Returns the width of the map in pixels.

## Usage

```lua
map:pixel_width()
```

### Returns

| Name    | Type     | Description      |
| :------ | :------- | :--------------- |
| `width` | `number` | Width in pixels. |

## Examples

```lua
local map = crystal.assets.get("assets/maps/forest.lua");
local area = map:pixel_width() * map:pixel_height();
print(area);
```
