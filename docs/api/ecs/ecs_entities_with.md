---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# ECS:entities_with

Returns all entities that have a [Component](component) of a specific class or inheriting from it.

{: .note}
The same data can obtained by creating a [Query](query) matching on a single component class. Both techniques have about the same performance (`O(n)` where n is number of entities returned). Using a query requires a bit more ceremony but also gives you a way to tell when entities receive/lose the required component. Using this method has the benefit of returning immediately up to date results, while queries are only updated during [ECS:update](ecs_update).

## Usage

```lua
ecs:entities_with(class)
```

### Arguments

| Name    | Type                        | Description                                                                   |
| :------ | :-------------------------- | :---------------------------------------------------------------------------- |
| `class` | `string` or component class | The component class that must be present on entities for them to be returned. |

### Returns

| Name       | Type    | Description                                     |
| :--------- | :------ | :---------------------------------------------- |
| `entities` | `table` | A table where every key is an [Entity](entity). |

## Example

```lua
local Health = Class("Health", crystal.Component);
local ecs = crystal.ECS:new();
local warrior = ecs:spawn(crystal.Entity);
local fairy = ecs:spawn(crystal.Entity);
local save_point = ecs:spawn(crystal.Entity);
warrior:add_component("Health");
fairy:add_component("Health");

-- Loop over warrior and fairy, but not save_point
for entity in pairs(ecs:entities_with("Health")) do
  -- Do something with entities that have a health component
end
```
