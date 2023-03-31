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

| Name                    | Description |
| :---------------------- | :---------- |
| draw                    |             |
| draw_offset             |             |
| draw_order              |             |
| set_draw_offset         |             |
| set_draw_order_modifier |             |

## Examples

```lua

```
