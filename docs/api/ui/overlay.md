---
parent: crystal.ui
grand_parent: API Reference
nav_order: 2
---

# crystal.Overlay

A [Container](container) which aligns children relatively to itself. The desired size of an overlay is the size of its largest child. All children are positioned within this space according to their alignment preferences (in a corner, centered, stretched, etc.).

Children of an overlay have [Overlay Joints](overlay_list_joint) associated with them to adjust positioning preferences (padding, alignment, etc.).

## Constructor

```lua
crystal.Overlay:new()
```

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
