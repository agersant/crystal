---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# Collider:shape

Returns the shape of this collider.

## Usage

```lua
collider:shape()
```

### Returns

| Name    | Type                                        | Description             |
| :------ | :------------------------------------------ | :---------------------- |
| `shape` | [love.Shape](https://love2d.org/wiki/Shape) | Shape of this collider. |

## Examples

```lua
local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local hero = ecs:spawn(crystal.Entity);
hero:add_component(crystal.Body);
hero:add_component(crystal.Collider, love.physics.newCircleShape(4));
print(hero:shape():getRadius()); -- Prints "4"
```
