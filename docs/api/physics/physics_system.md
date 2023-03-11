---
parent: crystal.physics
grand_parent: API Reference
---

# crystal.PhysicsSystem

This ECS [System](system) powers [Body](body), [Movement](movement), [Collider](collider) and [Sensor](sensor) components.

When it receives the `simulate_physics` [notification](/crystal/api/ecs/ecs_notify_systems), this system:

1. Activates or destroys the necessary [love.Body](https://love2d.org/wiki/Body) and [love.Fixture](https://love2d.org/wiki/Fixture) objects.
2. Gives each [Body](body) a linear velocity matching its desired [Movement](movement)
3. Updates the Box2D simulation
4. Calls on `begin_contact` / `end_contact` on all relevant [Collider](collider) and [Sensor](sensor) components.

## Examples
