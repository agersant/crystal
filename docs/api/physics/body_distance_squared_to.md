---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Body:distance_squared_to

Returns the distance squared between this entity and a specific location.

{: .note}
Distances squared are faster to compute than actual distances. This is useful when you need to compare distances but do not need their actual values.

## Usage

```lua
body:distance_squared_to(x, y)
```

### Arguments

| Name | Type     | Description                  |
| :--- | :------- | :--------------------------- |
| `x`  | `number` | x component of the location. |
| `y`  | `number` | y component of the location. |

### Returns

| Name               | Type     | Description                                 |
| :----------------- | :------- | :------------------------------------------ |
| `distance_squared` | `number` | Distance squared to the specified location. |

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local hero = ecs:spawn(crystal.Entity);
hero:add_component(crystal.Body);
hero:set_position(0, 0);

print(hero:distance_squared_to(10, 0)); -- Prints "100"
```
