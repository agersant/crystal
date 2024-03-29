---
parent: crystal.physics
grand_parent: API Reference
nav_order: 2
---

# crystal.Sensor

[Component](/crystal/api/ecs/component) allowing an entity to detect collision with others without blocking them. Freshly created sensors have no [category](sensor_set_categories) and [are activated by nothing](sensor_enable_activation_by).

In a typical platforming game, collectable coins and power-ups would use sensor components.

## Constructor

Like all other components, Sensor components are created by calling [Entity:add_component](/crystal/api/ecs/entity_add_component). The constructor expects one argument: a [love.Shape](https://love2d.org/wiki/Shape). The entity must have a [Body](body) component added prior to adding any sensors.

```lua
entity:add_component(crystal.Body);
entity:add_component(crystal.Sensor, love.physics.newCircleShape(4));
```

## Methods

| Name                                                                        | Description                                                                               |
| :-------------------------------------------------------------------------- | :---------------------------------------------------------------------------------------- |
| [activations](sensor_activations)                                           | Returns all components currently overlapping this sensor.                                 |
| [disable_activation_by](sensor_disable_activation_by)                       | Prevents this sensor from being activated by colliders or sensors of specific categories. |
| [disable_activation_by_everything](sensor_disable_activation_by_everything) | Prevents this sensor from being activated by colliders or sensors of any category.        |
| [disable_sensor](sensor_disable_sensor)                                     | Prevents this sensor from being activated.                                                |
| [enable_activation_by](sensor_enable_activation_by)                         | Allows this sensor to be activated by colliders or sensors of specific categories.        |
| [enable_activation_by_everything](sensor_enable_activation_by_everything)   | Allows this sensor to be activated by colliders or sensors of any category.               |
| [enable_sensor](sensor_enable_sensor)                                       | Allows this sensor to be activated.                                                       |
| [set_categories](sensor_set_categories)                                     | Sets which physics categories describe this sensor.                                       |
| [shape](sensor_shape)                                                       | Returns the shape of this sensor.                                                         |

## Callbacks

| Name                                  | Description                                                      |
| :------------------------------------ | :--------------------------------------------------------------- |
| [on_activate](sensor_on_activate)     | Called when a collider or sensor starts overlapping this sensor. |
| [on_deactivate](sensor_on_deactivate) | Called when a collider or sensor stops overlapping this sensor.  |

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local pressure_plate = ecs:spawn(crystal.Entity);
pressure_plate:add_component(crystal.Body);

local sensor = pressure_plate:add_component(crystal.Sensor, love.physics.newRectangleShape(20, 20));
sensor:set_categories("trigger");
sensor:enable_activation_by("characters");
sensor.on_activate = function()
  print("Pressure plate activated!");
end
```
