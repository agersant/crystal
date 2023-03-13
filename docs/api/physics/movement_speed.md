---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Movement:speed

Returns how fast this entity can move.

## Usage

```lua
movement:speed()
```

### Returns

| Name    | Type     | Description                   |
| :------ | :------- | :---------------------------- |
| `speed` | `number` | Movement speed in pixels / s. |

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.Body, "dynamic");
entity:add_component(crystal.Movement);
entity:set_speed(100);
print(entity:speed()); -- Prints "100"
```
