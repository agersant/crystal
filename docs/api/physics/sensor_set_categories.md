---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Sensor:set_categories

Sets which physics categories describe this sensor.

Categories are used to determine which [colliders](collider) and [sensors](sensor) are allowed to interact with each other. The list of valid categories in your project must be defined using [crystal.configure](/crystal/api/configure).

## Usage

```lua
sensor:set_categories(...)
```

### Arguments

| Name  | Type     | Description                                |
| :---- | :------- | :----------------------------------------- |
| `...` | `string` | Physics categories describing this sensor. |

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
