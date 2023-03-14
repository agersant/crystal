---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Body:apply_impulse

Applies a [linear impulse](https://love2d.org/wiki/Body:applyLinearImpulse) to the underlying [love.Body](https://love2d.org/wiki/Body).

The body's position will not be affected until the next step of the physics simulation, usually ran via [PhysicsSystem](physics_system).

## Usage

```lua
body:apply_impulse(x, y)
```

### Arguments

| Name | Type     | Description                     |
| :--- | :------- | :------------------------------ |
| `x`  | `number` | The x component of the impulse. |
| `y`  | `number` | The y component of the impulse. |

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.Body);
entity:apply_impulse(100, -50);
```
