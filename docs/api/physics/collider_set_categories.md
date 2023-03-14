---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Collider:set_categories

Sets which physics categories describe this collider.

Categories are used to determine which [colliders](collider) and [sensors](sensor) are allowed to interact with each other. The list of valid categories in your project must be defined using [crystal.configure](/crystal/api/configure).

## Usage

```lua
collider:set_categories(...)
```

### Arguments

| Name  | Type     | Description                                  |
| :---- | :------- | :------------------------------------------- |
| `...` | `string` | Physics categories describing this collider. |

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
