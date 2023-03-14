---
parent: crystal.physics
grand_parent: API Reference
---

# crystal.Body

A [Component](/crystal/api/ecs/component) representing an entity's position in space and other physics parameters. Entities should have at most one Body component.

## Constructor

Like all other components, `Body` components are created by calling [Entity:add_component](/crystal/api/ecs/entity_add_component). The constructor expects one arguments: a [love.BodyType](https://love2d.org/wiki/BodyType) for the underlying [love.Body](https://love2d.org/wiki/Body).

```lua
entity:add_component(crystal.Body, "dynamic");
```

## Methods

| Name                                                          | Description                                                                                                                                |
| :------------------------------------------------------------ | :----------------------------------------------------------------------------------------------------------------------------------------- | --- |
| [apply_impulse](body_apply_impulse)                           | Applies a [linear impulse](https://love2d.org/wiki/Body:applyLinearImpulse) to the underlying [love.Body](https://love2d.org/wiki/Body).   |
| [attach_to](body_attach_to)                                   | Links this entity to another one, relinquishing control of its position.                                                                   |
| [damping](body_damping)                                       | Returns the [linear damping](https://love2d.org/wiki/Body:getLinearDamping) of the underlying [love.Body](https://love2d.org/wiki/Body).   |
| [detach_from_parent](body_detach_from_parent)                 | Unlinks this entity from any parent it was attached to.                                                                                    |
| [distance_squared_to_entity](body_distance_squared_to_entity) | Returns the squared of the distance between this entity and another one.                                                                   |
| [distance_squared_to](body_distance_squared_to)               | Returns the square of the distance between this entity and a specific location.                                                            |
| [distance_to_entity](body_distance_to_entity)                 | Returns the distance between this entity and another one.                                                                                  |
| [distance_to](body_distance_to)                               | Returns the distance between this entity and a specific location.                                                                          |
| [look_at](body_look_at)                                       | Sets this entity's rotation so that it faces a specific location.                                                                          |
| [position](body_position)                                     | Returns this entity's position.                                                                                                            |
| [rotation](body_rotation)                                     | Returns this entity's rotation.                                                                                                            |
| [set_damping](body_set_damping)                               | Sets the [linear damping](https://love2d.org/wiki/Body:getLinearDamping) of the underlying [love.Body](https://love2d.org/wiki/Body).      |
| [set_position](body_set_position)                             | Sets this entity's position.                                                                                                               |     |
| [set_rotation](body_set_rotation)                             | Sets this entity's rotation.                                                                                                               |
| [set_velocity](body_set_velocity)                             | Sets the [linear velocity](https://love2d.org/wiki/Body:getLinearVelocity) of the underlying [love.Body](https://love2d.org/wiki/Body).    |
| [velocity](body_velocity)                                     | Returns the [linear velocity](https://love2d.org/wiki/Body:getLinearVelocity) of the underlying [love.Body](https://love2d.org/wiki/Body). |

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local monster_positions = {
  {100, 200},
  {40, 87},
  {-100, 130},
};

for _, position in ipairs(monster_positions) do
  local monster = ecs:spawn(crystal.Entity);
  monster:add_component(crystal.Body, "dynamic");
  monster:set_position(position[1], position[2]);
end
```
