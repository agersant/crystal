---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Sensor:disable_sensor

Prevents this sensor from being activated.

## Usage

```lua
sensor:disable_sensor()
```

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local pressure_plate = ecs:spawn(crystal.Entity);
pressure_plate:add_component(crystal.Body);
pressure_plate:add_component(crystal.Sensor, love.physics.newCircleShape(4));
pressure_plate:set_categories("triggers");
pressure_plate:enable_activation_by("players");

pressure_plate.set_pressure_plate_enabled = function(self, enabled)
  if enabled then
    self:disable_sensor();
  else
    self:enable_sensor();
  end
end
```
