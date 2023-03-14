---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Sensor:shape

Returns the shape of this sensor.

## Usage

```lua
sensor:shape()
```

### Returns

| Name    | Type                                        | Description           |
| :------ | :------------------------------------------ | :-------------------- |
| `shape` | [love.Shape](https://love2d.org/wiki/Shape) | Shape of this sensor. |

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local pressure_plate = ecs:spawn(crystal.Entity);
pressure_plate:add_component(crystal.Body);
pressure_plate:add_component(crystal.Sensor, love.physics.newCircleShape(4));
print(pressure_plate:shape():getRadius()); -- Prints "4"
```
