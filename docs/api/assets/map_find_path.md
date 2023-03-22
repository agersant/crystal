---
parent: crystal.assets
grand_parent: API Reference
nav_exclude: true
---

# Map:find_path

Computes an unobstructed path between two map locations. This function may return `nil` if no valid path was found.

## Usage

```lua
map:find_path(start_x, start_y, destination_x, destination_y)
```

### Arguments

| Name            | Type     | Description                             |
| :-------------- | :------- | :-------------------------------------- |
| `start_x`       | `number` | X coordinate of path starting position. |
| `start_y`       | `number` | Y coordinate of path starting position. |
| `destination_x` | `number` | X coordinate of the destination.        |
| `destination_y` | `number` | Y coordinate of the destination.        |

### Returns

| Name   | Type    | Description                              |
| :----- | :------ | :--------------------------------------- |
| `path` | `table` | Computed path, or nil if none was found. |

The `path` table is a list where each entry is a `{x, y}` waypoint position. The first waypoint is `{ start_x, start_y }` and the final one is `{ destination_x, destination_y }`.

## Examples

```lua
local map = crystal.assets.get("assets/maps/forest.lua");
local path = map:find_path(100, 20, 256, 400);
for _, waypoint in ipairs(path) do
  print(waypoint[1], waypoint[2]);
end
```
