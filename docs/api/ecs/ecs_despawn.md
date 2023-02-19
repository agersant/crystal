---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# ECS:despawn

Unregisters an [Entity](entity) from this ECS. See [Entity:despawn](entity_despawn) for more details.

## Usage

```lua
ecs:despawn(entity)
```

### Arguments

| Name     | Type             | Description            |
| :------- | :--------------- | :--------------------- |
| `entity` | [Entity](entity) | The entity to depsawn. |

## Example

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
ecs:despawn(entity);
```
