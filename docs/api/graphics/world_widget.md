---
parent: crystal.graphics
grand_parent: API Reference
---

# crystal.WorldWidget

A [Drawable](drawable) component that can draw a UI [Widget](/crystal/api/ui/widget).

## Constructor

Like all other components, WorldWidget components are created by calling [Entity:add_component](/crystal/api/ecs/entity_add_component).

The constructor for WorldWidget expects one optional argument, a [Widget](/crystal/api/ui/widget).

## Methods

| Name                                                | Description                                                           |
| :-------------------------------------------------- | :-------------------------------------------------------------------- |
| [set_widget](world_widget_set_widget)               | Sets the widget managed by this component.                            |
| [set_widget_anchor](world_widget_set_widget_anchor) | Sets how to align the widget when drawing it.                         |
| [update_widget](world_widget_update_widget)         | Updates and computes layout for the widget managed by this component. |

## Examples

```lua
local MyWidget = Class("MyWidget", crystal.Widget);
MyWidget.init = function(self)
  MyWidget.super.init(self);
end

local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.WorldWidget, MyWidget:new());
```
