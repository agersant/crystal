---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Body:set_velocity

Sets the [linear velocity](https://love2d.org/wiki/Body:getLinearVelocity) of the underlying [love.Body](https://love2d.org/wiki/Body).

## Usage

```lua
body:set_velocity(vx, vy)
```

### Arguments

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
hero:set_velocity(50, 0);

ecs:update();
for i = 1, 100 do
  ecs:notify_systems("simulate_physics");
end
local x, y = hero:position();
print(x); -- Prints a value very close to 50
```
