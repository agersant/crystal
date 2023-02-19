---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# Entity:despawn

Unregisters this entity from the [ECS](ecs). The implications of despawning an entity are:

- Calling its [is_valid](entity_is_valid) method returns return `false`.
- Calling its [add_component](entity_add_component), [remove_component](entity_remove_component) or [create_event](entity_create_event) method emits an error.
- The entity no longer appears in return values of any method from its [ECS](ecs).
- After the next call to [ECS:update](ecs_update), this entity will no longer be matched by any [Query](query).

Note that there is no safeguard preventing you from holding references to entities after despawning them.

Attempting to despawn an entity multiple times will emit an error.

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
