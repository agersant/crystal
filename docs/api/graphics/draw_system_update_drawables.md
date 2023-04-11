---
parent: crystal.graphics
grand_parent: API Reference
nav_exclude: true
---

# DrawSystem:update_drawables

Runs update logic for drawables that have any. This involves:

1. Updating the current keyframe of all [AnimatedSprite](animated_sprite) components.
2. Updating the script and layout of all [WorldWidget](world_widget) components.

{: .note}
If you have unrelated scripts [joining](/crystal/api/script/thread_join) on threads managed by these components (such as threads returned by [AnimatedSprite:play_animation](animated_sprite_play_animation)), they may resume execution during this call.

## Usage

```lua
draw_system:update_drawables(delta_time)
```

### Arguments

| Name         | Type     | Description                             |
| :----------- | :------- | :-------------------------------------- |
| `delta_time` | `number` | Time since previous update, in seconds. |

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
