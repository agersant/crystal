---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# Entity:component

Returns a [Component](component) of a specific class or inheriting from it.

## Usage

```lua
entity:component(class)
```

### Arguments

| Name    | Type                        | Description                                                                                  |
| :------ | :-------------------------- | :------------------------------------------------------------------------------------------- |
| `class` | `string` or component class | The component class to look up in this entity's components, as a `string` or as a reference. |

### Returns

| Name        | Type                   | Description                                                                    |
| :---------- | :--------------------- | :----------------------------------------------------------------------------- |
| `component` | [Component](component) | A component on this entity that is of the specified class or inherits from it. |

If the entity has no component of the specified class (or inheriting from it), this method returns `nil`.

If the entity has multiple components of the specified class (or inheriting from it), this method may return any of them.

## Examples

```lua
local Health = Class("Health", crystal.Component);
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
local health = entity:add_component("Health");
assert(entity:component("Health") == health);
```
