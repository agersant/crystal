---
parent: crystal.physics
grand_parent: API Reference
---

# crystal.Movement

[Component](/crystal/api/ecs/component) allowing an entity to move of its own volition. Entities should have at most one Movement component.

Expected usage of this component is to call [set_heading](movement_set_heading) every frame in response to player inputs or AI logic. Every frame, the [PhysicsSystem]:

- Sets the entity's linear velocity to match the [heading](movement_set_heading) and [speed](movement_set_speed) of its movement component.
- Sets the rotation of the entity's [Body](body) to match the [heading](movement_set_heading) of its movement component.

A `nil` heading indicates that the entity is standing still. Its velocity will be zero'ed out by the [PhysicsSystem](physics_system).

Disabling a movement component makes it relinquish control of the entity's velocity.

{: .note}
Entities using this component should have a [Body](body) with the `dynamic` or `kinematic` body type.

## Constructor

Like all other components, Movement components are created by calling [Entity:add_component](/crystal/api/ecs/entity_add_component). This constructor takes one optional `number` parameter initializing movement speed. Its default value is 10 pixels / s.

```lua
local movement_speed = 20; -- pixels / s
entity:add_component(crystal.Movement, movement_speed);
```

## Methods

| Name                                                | Description                                                      |
| :-------------------------------------------------- | :--------------------------------------------------------------- |
| [disable_movement](movement_disable_movement)       | Prevents this component from affecting entity physics.           |
| [enable_movement](movement_enable_movement)         | Allows this component to affect entity physics.                  |
| [heading](movement_heading)                         | Returns the direction this entity is attempting to move towards. |
| [is_movement_enabled](movement_is_movement_enabled) | Returns whether this movement component is currently enabled.    |
| [set_heading](movement_set_heading)                 | Sets the direction this entity is attempting to move towards.    |
| [set_speed](movement_set_speed)                     | Sets how fast this entity can move.                              |
| [speed](movement_speed)                             | Returns how fast this entity can move.                           |

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.Body);
entity:add_component(crystal.Movement);
entity:set_heading(0); -- in radians

for i = 1, 100 do
  ecs:update();
  ecs:notify_systems("simulate_physics");
  print(entity:position()); -- Prints entity position as it's moving to the right
end
```
