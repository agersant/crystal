---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Collider:set_restitution

Sets the [restitution coefficient](https://love2d.org/wiki/Fixture:setRestitution) of this collider.

## Usage

```lua
collider:set_restitution(restitution)
```

### Arguments

| Name          | Type     | Description              |
| :------------ | :------- | :----------------------- |
| `restitution` | `number` | Restitution coefficient. |

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local hero = ecs:spawn(crystal.Entity);
hero:add_component(crystal.Body);
hero:add_component(crystal.Collider, love.physics.newCircleShape(4));
hero:set_restitution(0.1);
```
