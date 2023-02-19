---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# Entity:despawn

Unregisters this entity from the [ECS](ecs). The implications of despawning an entity are:

- Calling its `is_valid` method now returns `false`.
- Calling [add_component](entity_add_component), [remove_component](entity_remove_component) or [create_event](entity_create_event) will emit an error.
- This entity no longer appears in return values of any method from its [ECS](ecs).
- After the next call to [ECS:update](ecs_update), this entity will no longer be matched by any [Query](query).

Note that there is no safeguard preventing you from holding references to entities after despawning them.

## Usage

```lua
entity:despawn()
```

## Example

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
entity:despawn();
```
