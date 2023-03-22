---
parent: crystal.assets
grand_parent: API Reference
nav_exclude: true
---

# Map:nearest_navigable_point

Projects a point onto the navigable part of the map. This function may return `nil` if the map has no walkable space.

## Usage

```lua
map:nearest_navigable_point(start_x, start_y)
```

### Arguments

| Name      | Type     | Description                              |
| :-------- | :------- | :--------------------------------------- |
| `start_x` | `number` | X coordinate of the position to project. |
| `start_y` | `number` | Y coordinate of the position to project. |

### Returns

| Name | Type     | Description                                  |
| :--- | :------- | :------------------------------------------- |
| `x`  | `number` | X coordinate of the nearest navigable point. |
| `y`  | `number` | Y coordinate of the nearest navigable point. |

## Examples

```lua
local map = crystal.assets.get("assets/maps/forest.lua");
local x, y = map:nearest_navigable_point(100, 80);
```
