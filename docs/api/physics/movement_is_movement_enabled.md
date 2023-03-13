---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Movement:is_movement_enabled

Returns whether this movement component is currently enabled.

## Usage

```lua
movement:is_movement_enabled()
```

### Returns

| Name      | Type      | Description                                             |
| :-------- | :-------- | :------------------------------------------------------ |
| `enabled` | `boolean` | True if movement is currently enabled, false otherwise. |

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.Body, "dynamic");
entity:add_component(crystal.Movement);
print(entity:is_movement_enabled()); -- Prints "True"
entity:disable_movement();
print(entity:is_movement_enabled()); -- Prints "False"
```
