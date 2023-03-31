---
parent: crystal.graphics
grand_parent: API Reference
---

# crystal.DrawOrder

A [Component](/crystal/api/ecs/component) that determines in what order entities are drawn. For more information on draw order, see [Drawable:drawable_set_draw_order_modifier](drawable_set_draw_order_modifier).

This base class is of little use without overriding the `draw_order()` method.

## Constructor

Like all other components, DrawOrder components are created by calling [Entity:add_component](/crystal/api/ecs/entity_add_component).

The constructor for DrawOrder expects no arguments.

## Methods

| Name         | Description                                                                          |
| :----------- | :----------------------------------------------------------------------------------- |
| `draw_order` | Returns the unmodified draw order (`number`) for drawable components on this entity. |

## Examples

This example defines a component class inheriting from `DrawOrder` to sort entities according to their `Y` position on the screen. This would be useful in a game using top-down perspective.

```lua
local YDrawOrder = Class("YDrawOrder", crystal.DrawOrder);
YDrawOrder.draw_order = function(self)
	local x, y = self:entity():position();
	return y;
end

local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.Body);
entity:add_component(crystal.Sprite);
entity:add_component(YDrawOrder);
```
