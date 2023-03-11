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
| angle                      |             |
| angle4                     |             |
| apply_linear_impulse       |             |
| attach_to                  |             |
| damping                    |             |
| detach_from_parent         |             |
| direction4                 |             |
| distance_to                |             |
| distance_to_entity         |             |
| distance_squared_to        |             |
| distance_squared_to_entity |             |
| look_at                    |             |
| position                   |             |
| set_angle                  |             |
| set_damping                |             |
| set_direction8             |             |
| set_position               |             |
| set_velocity               |             |
| velocity                   |             |

## Examples