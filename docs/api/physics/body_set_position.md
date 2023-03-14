---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Body:set_position

Sets this entity's position.

## Usage

```lua
body:set_position(x, y)
```

### Arguments

| Name | Type     | Description                  |
| :--- | :------- | :--------------------------- |
| `x`  | `number` | x component of the position. |
| `y`  | `number` | y component of the position. |

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local hero = ecs:spawn(crystal.Entity);
hero:add_component(crystal.Body, "dynamic");
hero:set_position(50, 60);
local x, y = hero:position();
print(x); -- Prints "50
print(y); -- Prints "60
```
