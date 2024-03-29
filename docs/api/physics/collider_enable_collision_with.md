---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Collider:enable_collision_with

Allows this collider to collide with colliders or sensors of specific [categories](collider_set_categories).

## Usage

```lua
collider:enable_collision_with(...)
```

### Arguments

| Name  | Type     | Description                                                 |
| :---- | :------- | :---------------------------------------------------------- |
| `...` | `string` | Physics categories that should interact with this collider. |

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local monster = ecs:spawn(crystal.Entity);
monster:add_component(crystal.Body);
monster:add_component(crystal.Collider, love.physics.newCircleShape(4));
monster:set_categories("characters");
monster:enable_collision_with("level", "characters");
monster:disable_collision_with("powerups", "traps");
```
