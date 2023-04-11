---
parent: crystal.physics
grand_parent: API Reference
---

# crystal.PhysicsSystem

This ECS [System](system) manages a [love.World](https://love2d.org/wiki/World). It also powers [Body](body), [Movement](movement), [Collider](collider) and [Sensor](sensor) components.

When it receives the `draw_debug` [notification](/crystal/api/ecs/ecs_notify_systems), this system draws colored shapes representing all [Collider](collider) and [Sensor](sensor) components. The colors are determined by the categories of the corresponding component.

## Methods

| Name                                                | Description                                                                     |
| :-------------------------------------------------- | :------------------------------------------------------------------------------ |
| [simulate_physics](physics_system_simulate_physics) | Ticks the physics simulation.                                                   |
| [world](physics_system_world)                       | Returns the [love.World](https://love2d.org/wiki/World) managed by this system. |

## Examples

```lua
local ecs = crystal.ECS:new();
local physics_system = ecs:add_system(crystal.PhysicsSystem);
physics_system:world():setGravity(0, 10);
```
