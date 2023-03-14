---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Body:distance_to

Returns the distance between this entity and a specific location.

## Usage

```lua
body:distance_to(x, y)
```

### Arguments

| Name | Type     | Description                  |
| :--- | :------- | :--------------------------- |
| `x`  | `number` | x component of the location. |
| `y`  | `number` | y component of the location. |

### Returns

| Name       | Type     | Description                         |
| :--------- | :------- | :---------------------------------- |
| `distance` | `number` | Distance to the specified location. |

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local hero = ecs:spawn(crystal.Entity);
hero:add_component(crystal.Body, "dynamic");
hero:set_position(0, 0);

print(hero:distance_to(10, 0)); -- Prints "10"
```
