---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Body:attach_to

Links this entity to another one, relinquishing control of its position. Calling this immediately updates the position of this Body component to match the specified entity. Whenever the specified entity moves, via [set_position](body_set_position) or via the physics simulation, the attached entity will immediately move to the same position. Attempting to apply impulses or set velocity on attached entities has no effect.

The parent entity must have a [Body](body) component. If things are not working as intended, make sure the relevant entities have `dynamic` or `kinematic` body types.

{: .warning}
Creating a cycle of attached entities will cause an infinite loop.

## Usage

```lua
body:attach_to(other_entity)
```

### Arguments

| Name           | Type                              | Description              |
| :------------- | :-------------------------------- | :----------------------- |
| `other_entity` | [Entity](/crystal/api/ecs/entity) | The entity to attach to. |

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local hero = ecs:spawn(crystal.Entity);
hero:add_component(crystal.Body);

local backpack = ecs:spawn(crystal.Entity);
backpack:add_component(crystal.Body);
backpack:attach_to(hero);
```
