---
parent: crystal.graphics
grand_parent: API Reference
nav_exclude: true
---

# Sprite:quad

Returns the [love.Quad](https://love2d.org/wiki/Quad) used to crop the texture drawn by this component.

## Usage

```lua
sprite:quad()
```

### Returns

| Name   | Type                                      | Description                        |
| :----- | :---------------------------------------- | :--------------------------------- |
| `quad` | [love.Quad](https://love2d.org/wiki/Quad) | The quad to crop the texture with. |

## Examples

```lua
local quad = love.graphics.newQuad(0, 0, 16, 32);
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.Sprite);
entity:set_texture(crystal.assets.get("assets/double_door.png"));
entity:set_quad(quad);
assert(entity:quad() == quad);
```
