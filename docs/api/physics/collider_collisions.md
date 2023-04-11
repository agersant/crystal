---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Collider:collisions

Returns all components currently colliding with this collider.

## Usage

```lua
collider:collisions()
```

### Returns

| Name         | Type    | Description                                                                                                                                 |
| :----------- | :------ | :------------------------------------------------------------------------------------------------------------------------------------------ |
| `collisions` | `table` | A table where every key is a [Collider](collider) or [Sensor](sensor), and the values are their owning [entities](/crystal/api/ecs/entity). |

## Examples

```lua
local ecs = crystal.ECS:new();
local physics_system = ecs:add_system(crystal.PhysicsSystem);

local hero = ecs:spawn(crystal.Entity);
hero:add_component(crystal.Body);
hero:add_component(crystal.Collider, love.physics.newCircleShape(4));
hero:set_categories("characters");
hero:enable_collision_with("level", "characters");

local monster = ecs:spawn(crystal.Entity);
monster:add_component(crystal.Body);
monster:add_component(crystal.Collider, love.physics.newCircleShape(8));
monster:set_categories("characters");
monster:enable_collision_with("level", "characters");

ecs:update();
physics_system:simulate_physics(0.01);

local component, entity = next(hero:collisions());
assert(entity == monster);
assert(component == monster:component(crystal.Collider));
```
