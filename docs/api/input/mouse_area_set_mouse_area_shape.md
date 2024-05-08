---
parent: crystal.input
grand_parent: API Reference
nav_exclude: true
---

# MouseArea:set_mouse_area_shape

Sets the shape of the surface that responds to the mouse.

## Usage

```lua
mouse_area:set_mouse_area_shape(shape)
```

### Arguments

| Name    | Type                                        | Description                    |
| :------ | :------------------------------------------ | :----------------------------- |
| `shape` | [love.Shape](https://love2d.org/wiki/Shape) | Shape of the interactive area. |

## Examples

This example creates a circular mouse area and then changes its shape to a square.

```lua
local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.MouseArea, love.physics.newCircleShape(10));
entity:set_mouse_area_shape(love.physics.newRectangleShape(20, 20));
```
