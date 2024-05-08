---
parent: crystal.input
grand_parent: API Reference
nav_exclude: true
---

# MouseArea:mouse_area_shape

Returns the shape of the surface that responds to the mouse.

## Usage

```lua
mouse_area:mouse_area_shape()
```

### Returns

| Name    | Type                                        | Description                    |
| :------ | :------------------------------------------ | :----------------------------- |
| `shape` | [love.Shape](https://love2d.org/wiki/Shape) | Shape of the interactive area. |

## Examples

```lua
local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.MouseArea, love.physics.newCircleShape(10));
print(entity:mouse_area_shape():getRadius()); -- Prints "10"
```
