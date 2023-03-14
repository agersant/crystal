---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Sensor:disable_activation_by

Prevents this sensor from being activated by colliders or sensors of specific [categories](sensor_set_categories).

## Usage

```lua
sensor:disable_activation_by(...)
```

### Arguments

| Name  | Type     | Description                                                   |
| :---- | :------- | :------------------------------------------------------------ |
| `...` | `string` | Physics categories that should not interact with this sensor. |

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local pressure_plate = ecs:spawn(crystal.Entity);
pressure_plate:add_component(crystal.Body);
pressure_plate:add_component(crystal.Sensor, love.physics.newCircleShape(4));
pressure_plate:set_categories("triggers");
pressure_plate:enable_activation_by("characters");
pressure_plate:disable_activation_by("monsters", "npc");
```
