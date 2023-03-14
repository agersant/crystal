---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Body:rotation

Returns this entity's rotation. A rotation of 0 indicates an entity facing right, positive rotations are interpreted as counter-clockwise.

## Usage

```lua
body:rotation()
```

### Returns

| Name       | Type     | Description          |
| :--------- | :------- | :------------------- |
| `rotation` | `number` | Rotation in radians. |

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local hero = ecs:spawn(crystal.Entity);
hero:add_component(crystal.Body);
hero:set_rotation(math.pi);
print(hero:rotation()); -- Prints "3.1415..."
```
