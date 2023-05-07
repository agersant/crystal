---
parent: crystal.ui
grand_parent: API Reference
nav_order: 2
---

# crystal.RoundedCorners

A [Painter](painter) which crops the corners of its child.

## Constructor

```lua
crystal.RoundedCorners:new(radius)
```

If ommitted, the default corner radius is `2` pixels.

## Methods

| Name                                                               | Description                                     |
| :----------------------------------------------------------------- | :---------------------------------------------- |
| [set_radius_bottom_left](rounded_corners_set_radius_bottom_left)   | Sets the bottom left corner radius.             |
| [set_radius_bottom_right](rounded_corners_set_radius_bottom_right) | Sets the bottom right corner radius.            |
| [set_radius_top_left](rounded_corners_set_radius_top_left)         | Sets the top left corner radius.                |
| [set_radius_top_right](rounded_corners_set_radius_top_right)       | Sets the top right corner radius.               |
| [set_radius](rounded_corners_set_radius)                           | Sets the corner radius for all corners at once. |

## Examples

This example creates an image with rounded corners:

```lua
local rounded_corners = crystal.RoundedCorners:new(8);
rounded_corners:set_child(crystal.Image:new(crystal.assets.get("forest_icon.png")));
```
