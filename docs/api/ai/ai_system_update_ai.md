---
parent: crystal.ai
grand_parent: API Reference
nav_exclude: true
---

# AISystem:update_ai

Updates AI logic. This involves:

1. Computing new paths if applicable
2. Setting the [heading](/crystal/api/physics/movement_set_heading) to follow active paths

{: .note}
If you have unrelated scripts [joining](/crystal/api/script/thread_join) on threads managed by these components (such as threads returned by [Navigation:navigate_to](navigation_navigate_to)), they may resume execution during this call.

## Usage

```lua
ai_system:update_ai(delta_time)
```

### Arguments

| Name         | Type     | Description                     |
| :----------- | :------- | :------------------------------ |
| `delta_time` | `number` | Time elapsed since last update. |

## Examples

```lua
local MyScene = Class("MyScene", crystal.Scene);

MyScene.init = function(self)
  self.ecs = crystal.ECS:new();
  self.ai_system = self.ecs:add_system(crystal.AISystem);
end

MyScene.update = function(self, delta_time)
  self.ai_system:update_ai(delta_time);
end
```
