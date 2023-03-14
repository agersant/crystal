---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Movement:set_heading

Sets the direction this entity is attempting to move towards.

A `nil` heading indicates that the entity is not trying to move.

## Usage

```lua
movement:set_heading(heading)
```

### Arguments

| Name      | Type     | Description                   |
| :-------- | :------- | :---------------------------- |
| `heading` | `number` | Heading direction in radians. |

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.Body);
entity:add_component(crystal.Movement);
entity:set_heading(math.pi);
print(entity:heading()); -- Prints "3.1415..."
```
