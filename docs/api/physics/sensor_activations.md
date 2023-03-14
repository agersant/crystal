---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Sensor:activations

Returns all components currently activating this sensor.

## Usage

```lua
sensor:activations()
```

### Returns

| Name          | Type    | Description                                                                                                                             |
| :------------ | :------ | :-------------------------------------------------------------------------------------------------------------------------------------- |
| `activations` | `table` | A table where every key is a [Sensor](sensor) or [Sensor](sensor), and the values are their owning [entities](/crystal/api/ecs/entity). |

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local hero = ecs:spawn(crystal.Entity);
hero:add_component(crystal.Body);
hero:add_component(crystal.Collider, love.physics.newCircleShape(4));
hero:set_categories("characters");
hero:enable_collision_with("level", "triggers");

local pressure_plate = ecs:spawn(crystal.Entity);
pressure_plate:add_component(crystal.Body);
pressure_plate:add_component(crystal.Sensor, love.physics.newCircleShape(8));
pressure_plate:set_categories("triggers");
pressure_plate:enable_activation_by("characters");

ecs:update();
ecs:notify_systems("simulate_physics");

local component, entity = next(hero:activations());
assert(entity == hero);
assert(component == hero:component(crystal.Collider));
```
