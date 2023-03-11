---
parent: crystal.physics
grand_parent: API Reference
---

# crystal.Movement

## Constructor

Like all other components, `Movement` components are created by calling [Entity:add_component](/crystal/api/ecs/entity_add_component).

## Methods

| Name                | Description                                                   |
| :------------------ | :------------------------------------------------------------ |
| disable_movement    | Prevents this component from affecting entity physics.        |
| enable_movement     | Allows this component to affect entity physics.               |
| heading             | Returns the direction this entity is moving towards.          |
| is_movement_enabled | Returns whether this movement component is currently enabled. |
| set_heading         | Sets the direction this entity is moving towards.             |
| set_speed           | Sets how fast this entity can move.                           |
| speed               | Returns how fast this entity can move.                        |

## Examples
