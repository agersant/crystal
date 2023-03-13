---
parent: crystal.physics
grand_parent: API Reference
---

# crystal.PhysicsSystem

This ECS [System](system) manages a [love.World](https://love2d.org/wiki/World). It also powers [Body](body), [Movement](movement), [Collider](collider) and [Sensor](sensor) components.

When it receives the `simulate_physics` [notification](/crystal/api/ecs/ecs_notify_systems), this system:

1. Activates or destroys [love.Body](https://love2d.org/wiki/Body) and [love.Fixture](https://love2d.org/wiki/Fixture) objects.
2. Gives each [Body](body) a linear velocity matching its desired [Movement](movement).
3. [Updates](https://love2d.org/wiki/World:update) the Box2D simulation.
4. Calls `on_collide` / `on_uncollide` / `on_activate` / `on_deactivate` on the relevant [Collider](collider) and [Sensor](sensor) components.

## Methods

| Name  | Description                                                                     |
| :---- | :------------------------------------------------------------------------------ |
| world | Returns the [love.World](https://love2d.org/wiki/World) managed by this system. |

## Examples

```lua
local ecs = crystal.ECS:new();
local physics_system = ecs:add_system(crystal.PhysicsSystem);
physics_system:world():setGravity(0, 10);
```
