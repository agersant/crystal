---
parent: crystal.ui
grand_parent: API Reference
nav_order: 2
---

# crystal.Border

A [UI element](ui_element) which draws a border around itself.

## Constructor

```lua
crystal.Border:new()
```

Newly created borders have a thickness of `1px` and no rounding.

## Methods

| Name                                  | Description                                  |
| :------------------------------------ | :------------------------------------------- |
| [rounding](border_rounding)           | Returns the radius used for corner rounding. |
| [set_rounding](border_set_rounding)   | Sets the radius used for corner rounding.    |
| [set_thickness](border_set_thickness) | Sets the border thickness in pixels.         |
| [thickness](border_thickness)         | Returns the border thickness in pixels.      |

## Examples

This example creates a progress bar with a background, a fill and a border:

```lua
local progress_bar = crystal.Overlay:new();

local background = progress_bar:add_child(crystal.Image:new());
background:set_image_size(80, 10);
background:set_color(crystal.Color.magenta_purple);

local fill = progress_bar:add_child(crystal.Image:new());
fill:set_alignment("left", "stretch");
fill:set_padding(1);
fill:set_image_size(60, 1);
fill:set_color(crystal.Color.bara_red);

local border = progress_bar:add_child(crystal.Image:new());
border:set_alignment("stretch", "stretch");
border:set_color(crystal.Color.white);
```
