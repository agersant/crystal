---
parent: crystal.physics
grand_parent: API Reference
---

# crystal.Collider

## Constructor

Like all other components, `Collider` components are created by calling [Entity:add_component](/crystal/api/ecs/entity_add_component). The constructor expects two arguments: a [Body](body) and a [love.Shape](https://love2d.org/wiki/Shape).

```lua
local body = entity:add_component(crystal.Body, my_world, "dynamic");
entity:add_component(crystal.Collider, body, love.physics.newCircleShape(4));
```

## Methods

| Name                   | Description                                                                    |
| :--------------------- | :----------------------------------------------------------------------------- |
| collisions             | Returns all components currently touching or overlapping this collider.        |
| disable_collider       | Prevents this collider from colliding with others.                             |
| disable_collision_with | Prevents a physics category from colliding with this collider.                 |
| enable_collider        | Allows this collider to collide with others.                                   |
| enable_collision_with  | Allows a physics category to collide with this collider.                       |
| on_collide             | Called when a collider or sensor starts touching or overlapping this collider. |
| on_uncollide           | Called when a collider or sensor stops touching or overlapping this collider.  |
| set_categories         | Sets which physics categories describe this collider.                          |
| set_friction           | Sets friction coefficient of this collider.                                    |
| set_restitution        | Sets restitution coefficient of this collider.                                 |
| shape                  | Returns the shape of this collider.                                            |

## Examples
