---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Body:look_at

Sets this entity's rotation so that it faces a specific location.

## Usage

```lua
body:look_at(x, y)
```

### Arguments

| Name | Type     | Description                  |
| :--- | :------- | :--------------------------- |
| `x`  | `number` | x component of the location. |
| `y`  | `number` | y component of the location. |

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local hero = ecs:spawn(crystal.Entity);
hero:add_component(crystal.Body);
hero:set_position(0, 0);
hero:look_at(-100, 0);
print(hero:rotation()); -- Prints the approximate value of pi
```
