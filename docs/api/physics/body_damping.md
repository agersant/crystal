---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Body:damping

Returns the [linear damping](https://love2d.org/wiki/Body:getLinearDamping) of the underlying [love.Body](https://love2d.org/wiki/Body).

## Usage

```lua
body:damping()
```

### Returns

| Name      | Type     | Description            |
| :-------- | :------- | :--------------------- |
| `damping` | `number` | Linear damping amount. |

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.Body);
entity:set_damping(0.1);
print(entity:damping()); -- Prints "0.1"
```
