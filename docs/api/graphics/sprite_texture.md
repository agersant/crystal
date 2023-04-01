---
parent: crystal.graphics
grand_parent: API Reference
nav_exclude: true
---

# Sprite:texture

Returns the [love.Texture](https://love2d.org/wiki/Texture) drawn by this component.

## Usage

```lua
sprite:texture()
```

### Returns

| Name      | Type                                            | Description          |
| :-------- | :---------------------------------------------- | :------------------- |
| `texture` | [love.Texture](https://love2d.org/wiki/Texture) | The texture to draw. |

## Examples

```lua
local strabwerry = crystal.assets.get("assets/strawberry.png");
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.Sprite);
entity:set_texture(strabwerry);
assert(entity:texture() == strabwerry);
```
