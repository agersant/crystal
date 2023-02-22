---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# Entity:ecs

Returns the [ECS](ecs) this entity belongs to.

## Usage

```lua
entity:ecs()
```

### Returns

| Name  | Type       | Description                 |
| :---- | :--------- | :-------------------------- |
| `ecs` | [ECS](ecs) | ECS this entity belongs to. |

## Examples

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
assert(entity:ecs() == ecs);
```
