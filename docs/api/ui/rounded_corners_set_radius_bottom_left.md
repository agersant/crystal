---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# RoundedCorners:set_radius_bottom_left

Sets the bottom left corner radius.

## Usage

```lua
rounded_corners:set_radius_bottom_left(radius)
```

### Arguments

| Name     | Type     | Description    |
| :------- | :------- | :------------- |
| `radius` | `number` | Corner radius. |

## Examples

```lua
local rounded_corners = crystal.RoundedCorners:new(8);
rounded_corners:set_child(crystal.Image:new(crystal.assets.get("forest_icon.png")));
rounded_corners:set_radius_bottom_left(0);
```
