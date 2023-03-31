---
parent: crystal.graphics
grand_parent: API Reference
---

# crystal.Drawable

A base [Component](/crystal/api/ecs/component) for anything that can draw on the screen.

This base class is of little use without overriding the `draw()` method.

## Constructor

Like all other components, Drawable components are created by calling [Entity:add_component](/crystal/api/ecs/entity_add_component).

The constructor for Drawable expects no arguments.

## Methods

| Name                                                        | Description                                               |
| :---------------------------------------------------------- | :-------------------------------------------------------- |
| `draw`                                                      | Draws the component. Default implementation does nothing. |
| [draw_offset](drawable_draw_offset)                         | Returns the offset to use when drawing this entity.       |
| [draw_order](drawable_draw_order)                           | Returns the draw order of this Drawable.                  |
| [set_draw_offset](drawable_set_draw_offset)                 | Sets the offset to use when drawing this entity.          |
| [set_draw_order_modifier](drawable_set_draw_order_modifier) | Sets how the draw order of this Drawable is computed.     |

## Examples

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
local drawable = entity:add_component(crystal.Drawable);
drawable.draw = function(self)
  love.graphics.rectangle("fill", 20, 50, 60, 120);
end
```
