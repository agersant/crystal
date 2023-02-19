---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# Entity:remove_component

Removes a component from this entity.

{: .info}
Removed components cannot be added back or transfered to other entities, as [add_component](entity_add_component) always instantiates a new component.

## Usage

```lua
entity:remove_component(component)
```

### Arguments

| Name        | Type                   | Description              |
| :---------- | :--------------------- | :----------------------- |
| `component` | [Component](component) | The component to remove. |

## Example

```lua
local Health = Class("Health", crystal.Component);
local ecs = crystal.ECS:new();

local entity = ecs:spawn(crystal.Entity);
local health = entity:add_component("Health");
entity:remove_component(health);
assert(entity:component("Health") == nil);
```
