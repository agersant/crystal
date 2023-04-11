---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# PhysicsSystem:simulate_physics

Ticks the physics simulation. This involves:

1. Activating or destroying [love.Body](https://love2d.org/wiki/Body) and [love.Fixture](https://love2d.org/wiki/Fixture) objects.
2. Giving each [Body](body) a linear velocity matching its desired [Movement](movement).
3. [Updating](https://love2d.org/wiki/World:update) the Box2D simulation.
4. Calling `on_collide` / `on_uncollide` / `on_activate` / `on_deactivate` on the relevant [Collider](collider) and [Sensor](sensor) components.

## Usage

```lua
physics_system:simulate_physics(delta_time)
```

### Returns

| Name         | Type     | Description                       |
| :----------- | :------- | :-------------------------------- |
| `delta_time` | `number` | Duration to simulate, in seconds. |

## Examples

```lua
local MyScene = Class("MyScene", crystal.Scene);

MyScene.init = function(self)
  self.ecs = crystal.ECS:new();
  self.physics_system = self.ecs:add_system(crystal.PhysicsSystem);
end

MyScene.update = function(self, delta_time)
  self.physics_system:simulate_physics(delta_time);
end
```
