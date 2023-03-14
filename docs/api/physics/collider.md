---
parent: crystal.physics
grand_parent: API Reference
---

# crystal.Collider

[Component](/crystal/api/ecs/component) allowing an entity to collide with others. Freshly created colliders have no [category](collider_set_categories) and [collide with nothing](collider_enable_collision_with).

In a typical platforming game, characters, enemies and platforms would use Collider components.

## Constructor

Like all other components, `Collider` components are created by calling [Entity:add_component](/crystal/api/ecs/entity_add_component). The constructor expects one argument: a [love.Shape](https://love2d.org/wiki/Shape). The entity must have a [Body](body) component added prior to adding any colliders.

```lua
entity:add_component(crystal.Body);
entity:add_component(crystal.Collider, love.physics.newCircleShape(4));
```

## Methods

| Name                   | Description                                                    |
| :--------------------- | :------------------------------------------------------------- |
| collisions             | Returns all components currently colliding with this collider. |
| disable_collider       | Prevents this collider from colliding with others.             |
| disable_collision_with | Prevents a physics category from colliding with this collider. |
| enable_collider        | Allows this collider to collide with others.                   |
| enable_collision_with  | Allows a physics category to collide with this collider.       |
| set_categories         | Sets which physics categories describe this collider.          |
| set_friction           | Sets friction coefficient of this collider.                    |
| set_restitution        | Sets restitution coefficient of this collider.                 |
| shape                  | Returns the shape of this collider.                            |

## Callbacks

| Name         | Description                                                           |
| :----------- | :-------------------------------------------------------------------- |
| on_collide   | Called when a collider or sensor starts colliding with this collider. |
| on_uncollide | Called when a collider or sensor stops colliding with this collider.  |

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);
local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.Body);
entity:add_component(crystal.Collider, love.physics.newCircleShape(4));
entity:set_categories("characters");
entity:enable_collision_with("level", "characters");
```
