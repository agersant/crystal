---
parent: crystal.physics
grand_parent: API Reference
nav_exclude: true
---

# PhysicsSystem:world

Returns the [love.World](https://love2d.org/wiki/World) managed by this system.

## Usage

```lua
physics_system:world()
```

### Returns

| Name    | Type                                        | Description                           |
| :------ | :------------------------------------------ | :------------------------------------ |
| `world` | [love.World](https://love2d.org/wiki/World) | Physics world managed by this system. |

## Examples

```lua
local ecs = crystal.ECS:new();
local physics_system = ecs:add_system(crystal.PhysicsSystem);
physics_system:world():setGravity(0, 10);
```
