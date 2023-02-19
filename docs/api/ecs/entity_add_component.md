---
parent: crystal.ecs
grand_parent: API Reference
nav_exclude: true
---

# Entity:add_component

Instantiates and adds a new [Component](component) to this entity.

## Usage

```lua
entity:component(class, ...)
```

### Arguments

| Name    | Type                        | Description                                                          |
| :------ | :-------------------------- | :------------------------------------------------------------------- |
| `class` | `string` or component class | The component class to instantiate, as a `string` or as a reference. |
| `...`   | `any`                       | Arguments that are passed to the component's constructor.            |

### Returns

| Name        | Type                   | Description                              |
| :---------- | :--------------------- | :--------------------------------------- |
| `component` | [Component](component) | Component that was created by this call. |

## Example

```lua
local Arm = Class("Arm", crystal.Component);
Arm.init = function(self, side)
	self.side = side;
end

local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
local left_arm = entity:add_component(Arm, "left");
local right_arm = entity:add_component("Arm", "right");
assert(right_arm.side == "right");
```
