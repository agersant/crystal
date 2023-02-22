---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# Component:entity

Returns the [Entity](entity) this component belongs to.

## Usage

```lua
component:entity()
```

### Returns

| Name     | Type             | Description                       |
| :------- | :--------------- | :-------------------------------- |
| `entity` | [Entity](entity) | Entity this component belongs to. |

## Examples

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
local component = entity:add_component(crystal.Component);
assert(component:entity() == entity);
```
