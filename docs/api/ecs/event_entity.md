---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# Event:entity

Returns the [Entity](entity) that emitted this event.

## Usage

```lua
event:entity()
```

### Returns

| Name     | Type             | Description                     |
| :------- | :--------------- | :------------------------------ |
| `entity` | [Entity](entity) | Entity that emitted this event. |

## Examples

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
local event = entity:create_event(crystal.Event);
assert(event:entity() == entity);
```
