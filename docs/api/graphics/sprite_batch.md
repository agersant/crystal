---
parent: crystal.graphics
grand_parent: API Reference
---

# crystal.SpriteBatch

A [Drawable](drawable) component that can draw a [love.SpriteBatch](https://love2d.org/wiki/SpriteBatch).

## Constructor

Like all other components, SpriteBatch components are created by calling [Entity:add_component](/crystal/api/ecs/entity_add_component).

The constructor for SpriteBatch expects one optional argument, a [love.SpriteBatch](https://love2d.org/wiki/SpriteBatch).

## Methods

| Name                                              | Description                                                               |
| :------------------------------------------------ | :------------------------------------------------------------------------ |
| [set_sprite_batch](sprite_batch_set_sprite_batch) | Sets the [love.SpriteBatch](https://love2d.org/wiki/SpriteBatch) to draw. |

## Examples

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
local sprite_batch = love.graphics.newSpriteBatch(crystal.assets.get("assets/tiles.png"), 200);
entity:add_component(crystal.SpriteBatch, sprite_batch);
```
