---
parent: crystal.graphics
grand_parent: API Reference
nav_exclude: true
---

# DrawSystem:draw_entities

Draws all entities. This involves:

1. Sorting all [Drawable](drawable) components according to their [draw order](drawable_set_draw_order_modifier).
2. Iterating through all [Drawable](drawable) components and calling their `draw()` method. These draws are:
   - Surrounded by calls to the associated [draw effects](draw_effect)
   - Offset by the entity's position if it has a [Body](/crystal/api/physics/body)
   - Offset by the Drawable's [offset](drawable_set_draw_offset)

## Usage

```lua
draw_system:draw_entities()
```

## Examples

```lua
local MyScene = Class("MyScene", crystal.Scene);

MyScene.init = function(self)
  self.ecs = crystal.ECS:new();
  self.draw_system = self.ecs:add_system(crystal.DrawSystem);
end

MyScene.update = function(self, delta_time)
  self.draw_system:update_drawables(delta_time);
end

MyScene.draw = function(self)
  self.draw_system:draw_entities();
end
```
