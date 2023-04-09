---
parent: crystal.assets
grand_parent: API Reference
nav_exclude: true
---

# Map:pixel_size

Returns the size of the map in pixels.

## Usage

```lua
map:pixel_size()
```

### Returns

| Name     | Type     | Description           |
| :------- | :------- | :-------------------- |
| `width`  | `number` | Map width in pixels.  |
| `height` | `number` | Map height in pixels. |

## Examples

```lua
local map = crystal.assets.get("assets/maps/forest.lua");
local width, height = map:pixel_size();
print(width, height);
```
