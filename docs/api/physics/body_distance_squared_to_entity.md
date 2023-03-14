---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Body:distance_squared_to_entity

Returns the distance squared between this entity and another one. The other entity must have a [Body](body) component.

{: .note}
Distances squared are faster to compute than actual distances. This is useful when you want to compare distances but do not need their actual values.

## Usage

```lua
body:distance_squared_to_entity(other_entity)
```

### Arguments

| Name           | Type                              | Description                                  |
| :------------- | :-------------------------------- | :------------------------------------------- |
| `other_entity` | [Entity](/crystal/api/ecs/entity) | Entity whose distance to should be measured. |

### Returns

| Name               | Type     | Description                           |
| :----------------- | :------- | :------------------------------------ |
| `distance_squared` | `number` | Distance squared to the other entity. |

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local hero = ecs:spawn(crystal.Entity);
hero:add_component(crystal.Body);
hero:set_position(0, 0);

local coin = ecs:spawn(crystal.Entity);
coin:add_component(crystal.Body);
coin:set_position(10, 0);

print(hero:distance_squared_to_entity(coin)); -- Prints "100"
```
