---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Body:set_rotation

Sets this entity's rotation. A rotation of 0 indicates an entity facing right, positive rotations are interpreted as counter-clockwise.

{: .note}
Rotating Body components does not rotate the underlying [love.Body](https://love2d.org/wiki/Body). This allows [colliders](collider) and [sensors](sensor) to remain upright no matter what direction the entity is facing.

## Usage

```lua
body:set_rotation(rotation)
```

### Arguments

| Name       | Type     | Description          |
| :--------- | :------- | :------------------- |
| `rotation` | `number` | Rotation in radians. |

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local hero = ecs:spawn(crystal.Entity);
hero:add_component(crystal.Body, "dynamic");
hero:set_rotation(math.pi);
print(hero:rotation()); -- Prints "3.1415..."
```
