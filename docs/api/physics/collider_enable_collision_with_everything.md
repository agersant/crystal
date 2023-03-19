---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Collider:enable_collision_with_everything

Allows this collider to collide with colliders or sensors of any [category](collider_set_categories).

## Usage

```lua
collider:enable_collision_with_everything()
```

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local monster = ecs:spawn(crystal.Entity);
monster:add_component(crystal.Body);
monster:add_component(crystal.Collider, love.physics.newCircleShape(4));
monster:set_categories("characters");
monster:enable_collision_with_everything();
```
