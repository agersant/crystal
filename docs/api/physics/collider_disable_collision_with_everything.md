---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Collider:disable_collision_with_everything

Prevents this collider from colliding with colliders or sensors of any [category](collider_set_categories).

## Usage

```lua
collider:disable_collision_with_everything()
```

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local monster = ecs:spawn(crystal.Entity);
monster:add_component(crystal.Body);
monster:add_component(crystal.Collider, love.physics.newCircleShape(4));
monster:set_categories("characters");
monster:enable_collision_with("level", "characters");
monster:disable_collision_with_everything(); -- No longer collides with "level" or "characters"
```
