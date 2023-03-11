---
parent: crystal.physics
grand_parent: API Reference
---

# crystal.Sensor

## Constructor

Like all other components, `Sensor` components are created by calling [Entity:add_component](/crystal/api/ecs/entity_add_component). The constructor expects two arguments: a [Body](body) and a [love.Shape](https://love2d.org/wiki/Shape).

```lua
local body = entity:add_component(crystal.Body, my_world, "dynamic");
entity:add_component(crystal.Sensor, body, love.physics.newCircleShape(4));
```

## Methods

| Name                      | Description |
| :------------------------ | :---------- |
| active_contacts           |             |
| add_category_to_mask      |             |
| disable_activation_by     |             |
| disable_sensor            |             |
| enable_activation_by      |             |
| enable_sensor             |             |
| on_begin_contact          |             |
| on_end_contact            |             |
| remove_category_from_mask |             |
| set_categories            |             |
| shape                     |             |

## Examples
