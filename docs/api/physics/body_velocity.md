---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Body:velocity

## Usage

```lua
body:velocity()
```

### Returns

| Name | Type     | Description                  |
| :--- | :------- | :--------------------------- |
| `vx` | `number` | x component of the velocity. |
| `vy` | `number` | y component of the velocity. |

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local hero = ecs:spawn(crystal.Entity);
hero:add_component(crystal.Body, "dynamic");
hero:set_velocity(50, 10);
local vx, vy = hero:velocity();
print(vx); -- Prints "50"
print(vy); -- Prints "10"
```
