---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# ECS:components

Returns all components of a specific class or inheriting from it.

## Usage

```lua
ecs:components(class)
```

### Arguments

| Name    | Type                        | Description                                                                |
| :------ | :-------------------------- | :------------------------------------------------------------------------- |
| `class` | `string` or component class | The component class to list instances of, as a `string` or as a reference. |

### Returns

| Name         | Type    | Description                                                                       |
| :----------- | :------ | :-------------------------------------------------------------------------------- |
| `components` | `table` | A table where each key is a component of the specified class or inherits from it. |

## Examples

```lua
local Stat = Class("Stat", crystal.Component);
local Health = Class("Health", Stat);
local Mana = Class("Mana", Stat);

local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
entity:add_component("Health");
entity:add_component("Mana");

for component in pairs(ecs:components("Stat")) do
  -- Prints "Instance of class: Health" and "Instance of class: Mana"
  print(component);
end
```
