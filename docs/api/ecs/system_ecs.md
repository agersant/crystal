---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# System:ecs

Returns the [ECS](ecs) this system belongs to.

## Usage

```lua
system:ecs()
```

### Returns

| Name  | Type       | Description                 |
| :---- | :--------- | :-------------------------- |
| `ecs` | [ECS](ecs) | ECS this system belongs to. |

## Example

```lua
local ecs = crystal.ECS:new();
local system = ecs:add_system(crystal.System);
assert(system:ecs() == ecs);
```
