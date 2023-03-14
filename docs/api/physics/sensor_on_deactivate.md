---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Sensor:on_deactivate

Called when a collider or sensor stops overlapping this sensor. Default implementation does nothing.

## Usage

```lua
sensor.on_deactivate = function(self, other_component, other_entity, contact)
  -- your code here
end
```

### Arguments

| Name              | Type                                            | Description                                                        |
| :---------------- | :---------------------------------------------- | :----------------------------------------------------------------- |
| `other_component` | [Sensor](sensor) or [Sensor](sensor)            | Components this sensor was overlapping with.                       |
| `other_entity`    | [Entity](/crystal/api/ecs/entity)               | Entity that was activating the sensor, owner of `other_component`. |
| `contact`         | [love.Contact](https://love2d.org/wiki/Contact) | Contact generated by the overlap.                                  |

As the LOVE documentation recommends:

> The lifetimes of Contacts are short. When you receive them in callbacks, they may be destroyed immediately after the callback returns. Cache their values instead of storing Contacts directly.

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local healing_shrine = ecs:spawn(crystal.Entity);
healing_shrine:add_component(crystal.Body);
local sensor = coin:add_component(crystal.Sensor, love.physics.newRectangle(100, 100));
healing_shrine:set_categories("powerups");
healing_shrine:enable_collision_with("characters");

sensor.on_activate = function(self, other_component, other_entity, contact)
  other_entity:enable_shrine_regen();
end

sensor.on_deactivate = function(self, other_component, other_entity, contact)
  other_entity:disable_shrine_regen();
end
```