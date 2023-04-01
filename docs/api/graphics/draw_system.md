---
parent: crystal.graphics
grand_parent: API Reference
---

# crystal.DrawSystem

A [System](/crystal/api/ecs/system) that updates and draws [Drawable](drawable) components.

When it receives the `update_drawables(delta_time)` [notification](/crystal/api/ecs/ecs_notify_systems), this system:

1. Updates the current keyframe of all [AnimatedSprite](animated_sprite) components.
2. Updates the script and layout of all [WorldWidget](world_widget) components.

{: .note}
If you have unrelated scripts [joining](/crystal/api/script/thread_join) on threads managed by these components (such as threads returned by [AnimatedSprite:play_animation](animated_sprite_play_animation)), they may resume execution during this notification.

When it receives the `draw_entities` [notification](/crystal/api/ecs/ecs_notify_systems), this system will draw all entities on the screen. This involves:

1. Sorting all [Drawable](drawable) components according to their [draw order](drawable_set_draw_order_modifier).
2. Iterating through all [Drawable](drawable) components and calling their `draw()` method. These draws are:
   - Surrounded by calls to the associated [draw effects](draw_effect)
   - Offset by the entity's position if it has a [Body](/crystal/api/physics/body)
   - Offset by the Drawable's [offset](drawable_set_draw_offset)

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.DrawSystem);

-- During update logic:
ecs:notify_systems("update_drawables", delta_time);

-- During draw logic:
ecs:notify_systems("draw_entities");
```
