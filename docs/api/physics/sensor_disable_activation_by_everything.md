---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Sensor:disable_activation_by_everything

Prevents this sensor from being activated by colliders or sensors of any [category](sensor_set_categories).

## Usage

```lua
sensor:disable_activation_by_everything()
```

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local pressure_plate = ecs:spawn(crystal.Entity);
pressure_plate:add_component(crystal.Body);
pressure_plate:add_component(crystal.Sensor, love.physics.newCircleShape(4));
pressure_plate:set_categories("triggers");
pressure_plate:enable_activation_by("characters");
pressure_plate:disable_activation_by_everything(); -- Can no longer be activated by "characters"
```
