---
parent: crystal.ai
grand_parent: API Reference
---

# crystal.AISystem

A [System](/crystal/api/ecs/system) that updates [Navigation](navigation) components.

When using the `ShowNavigationOverlay` command and sending this system a `draw_debug` [notification](/crystal/api/ecs/ecs_notify_systems), it draws the navigation mesh and all active paths using it.

## Methods

| Name                             | Description       |
| :------------------------------- | :---------------- |
| [update_ai](ai_system_update_ai) | Updates AI logic. |

## Console Commands

| Name                    | Description                                          |
| :---------------------- | :--------------------------------------------------- |
| `HideNavigationOverlay` | Stops drawing the navigation mesh and active paths.  |
| `ShowNavigationOverlay` | Starts drawing the navigation mesh and active paths. |

## Examples

```lua
local MyScene = Class("MyScene", crystal.Scene);

MyScene.init = function(self)
  local map = crystal.assets.get("assets/map/dungeon.lua");
  self.ecs = crystal.ECS:new();
  self.ai_system = self.ecs:add_system(crystal.AISystem, map);
end

MyScene.update = function(self, delta_time)
  self.ai_system:update_ai(delta_time);
end
```
