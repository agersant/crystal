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

| Name                  | Description                                                      |
| :-------------------- | :--------------------------------------------------------------- |
| activations           | Returns all components currently overlapping this sensor.        |
| disable_activation_by | Prevents a physics category from activating this sensor.         |
| disable_sensor        | Prevents this sensor from being activated.                       |
| enable_activation_by  | Allows a physics category to activate this sensor.               |
| enable_sensor         | Allows this sensor to be activated.                              |
| on_activate           | Called when a collider or sensor starts overlapping this sensor. |
| on_deactivate         | Called when a collider or sensor stops overlapping this sensor.  |
| set_categories        | Sets which physics categories describe this sensor.              |
| shape                 | Returns the shape of this sensor.                                |

## Examples
