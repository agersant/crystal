---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# Entity:components

Returns all components on this entity that are of a specific class or inherit fom it.

## Usage

```lua
entity:components(class)
```

### Arguments

| Name    | Type                        | Description                                                                                  |
| :------ | :-------------------------- | :------------------------------------------------------------------------------------------- |
| `class` | `string` or component class | The component class to look up in this entity's components, as a `string` or as a reference. |

### Returns

| Name         | Type    | Description                                                                       |
| :----------- | :------ | :-------------------------------------------------------------------------------- |
| `components` | `table` | A table where each key is a component of the specified class or inherits from it. |

If the entity has no component of the specified class (or inheriting from it), this method returns an empty table.

## Example

```lua
local Arm = Class("Arm", crystal.Component);
Arm.init = function(self, side)
  self.side = side;
end

local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
local left_arm = entity:add_component("Arm", "left");
local right_arm = entity:add_component("Arm", "right");
for arm in entity:components("Arm") do
  print(arm.side);
end
```
