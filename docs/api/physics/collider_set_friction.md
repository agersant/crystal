---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Collider:set_friction

Sets the [friction coefficient](https://love2d.org/wiki/Fixture:setFriction) of this collider.

## Usage

```lua
collider:set_friction(friction)
```

### Arguments

| Name       | Type     | Description           |
| :--------- | :------- | :-------------------- |
| `friction` | `number` | Friction coefficient. |

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local hero = ecs:spawn(crystal.Entity);
hero:add_component(crystal.Body);
hero:add_component(crystal.Collider, love.physics.newCircleShape(4));
hero:set_friction(0.1);
```
