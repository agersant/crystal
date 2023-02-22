---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# Entity:is_valid

Returns whether this entity is still in play (ie. not despawned). See [Entity:despawn](entity_despawn) for more details.

## Usage

```lua
entity:is_valid()
```

### Returns

| Name    | Type      | Description                                                                |
| :------ | :-------- | :------------------------------------------------------------------------- |
| `valid` | `boolean` | False if this entity has been [despawned](entity_despawn), true otherwise. |

## Examples

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
assert(entity:is_valid());
entity:despawn();
assert(not entity:is_valid());
```
