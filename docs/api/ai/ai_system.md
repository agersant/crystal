---
parent: crystal.ai
grand_parent: API Reference
---

# crystal.AISystem

A [System](/crystal/api/ecs/system) that updates [Navigation](navigation) components.

When it receives the `update_ai(delta_time)` [notification](/crystal/api/ecs/ecs_notify_systems), this system:

1. Computes new paths if applicable
2. Sets the [heading](/crystal/api/physics/movement_set_heading) to follow active paths

{: .note}
If you have unrelated scripts [joining](/crystal/api/script/thread_join) on threads managed by these components (such as threads returned by [Navigation:navigate_to](navigation_navigate_to)), they may resume execution during this notification.

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.AISystem);

-- During update logic:
ecs:notify_systems("update_ai", delta_time);
```
