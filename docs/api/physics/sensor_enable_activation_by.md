---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Sensor:enable_activation_by

Allows this sensor to be activated by colliders or sensors of specific categories.

## Usage

```lua
sensor:enable_activation_by(...)
```

### Arguments

| Name  | Type     | Description                                               |
| :---- | :------- | :-------------------------------------------------------- |
| `...` | `string` | Physics categories that should interact with this sensor. |

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
