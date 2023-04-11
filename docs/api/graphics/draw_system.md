---
parent: crystal.graphics
grand_parent: API Reference
---

# crystal.DrawSystem

A [System](/crystal/api/ecs/system) that updates and draws [Drawable](drawable) components.

## Methods

| Name                                             | Description                                    |
| :----------------------------------------------- | :--------------------------------------------- |
| [draw_entities](draw_system_draw_entities)       | Draws all entities.                            |
| [update_drawables](draw_system_update_drawables) | Runs update logic for drawables that have any. |

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
  crystal.window.draw_upscaled(function()
    self.draw_system:draw_entities();
  end);
end
```
