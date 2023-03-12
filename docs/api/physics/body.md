---
parent: crystal.physics
grand_parent: API Reference
---

# crystal.Body

## Constructor

Like all other components, `Body` components are created by calling [Entity:add_component](/crystal/api/ecs/entity_add_component). The constructor expects two arguments: a [love.World](https://love2d.org/wiki/World) and a [love.BodyType](https://love2d.org/wiki/BodyType).

```lua
entity:add_component(crystal.Body, my_world, "dynamic");
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
