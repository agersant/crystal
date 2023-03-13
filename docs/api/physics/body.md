---
parent: crystal.physics
grand_parent: API Reference
---

# crystal.Body

A [Component](/crystal/api/ecs/component) representing an entity's position in space and other physics parameters.

## Constructor

Like all other components, `Body` components are created by calling [Entity:add_component](/crystal/api/ecs/entity_add_component). The constructor expects one arguments: a [love.BodyType](https://love2d.org/wiki/BodyType) for the underlying [love.Body](https://love2d.org/wiki/Body).

```lua
entity:add_component(crystal.Body, "dynamic");
```

## Methods

| Name                       | Description |
| :------------------------- | :---------- |
| apply_linear_impulse       |             |
| attach_to                  |             |
| damping                    |             |
| detach_from_parent         |             |
| distance_to                |             |
| distance_to_entity         |             |
| distance_squared_to        |             |
| distance_squared_to_entity |             |
| look_at                    |             |
| position                   |             |
| rotation                   |             |
| set_rotation               |             |
| set_damping                |             |
| set_position               |             |
| set_velocity               |             |
| velocity                   |             |

## Examples

```lua
local ecs = crystal.ECS:new();

local monster_positions = {
  {100, 200},
  {40, 87},
  {-100, 130},
};

for _, position in ipairs(monster_positions) do
  local monster = ecs:spawn(crystal.Entity);
  monster:add_component(crystal.Body, "dynamic");
  monster:set_position(position[1], position[2]);
end
```
