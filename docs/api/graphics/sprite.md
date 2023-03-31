---
parent: crystal.graphics
grand_parent: API Reference
---

# crystal.Sprite

A [Drawable](drawable) component that can draw a [love.Texture](https://love2d.org/wiki/Texture).

## Constructor

Like all other components, Sprite components are created by calling [Entity:add_component](/crystal/api/ecs/entity_add_component).

The constructor for Sprite expects two optional arguments, a [love.Texture](https://love2d.org/wiki/Texture) and a [love.Quad](https://love2d.org/wiki/Quad).

## Methods

| Name                              | Description                                                                                          |
| :-------------------------------- | :--------------------------------------------------------------------------------------------------- |
| [set_texture](sprite_set_texture) | Sets the [love.Texture](https://love2d.org/wiki/Texture) drawn by this component.                    |
| [set_quad](sprite_set_quad)       | Sets the [love.Quad](https://love2d.org/wiki/Quad) used to crop the texture drawn by this component. |

## Examples

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.Sprite, crystal.assets.get("assets/strawberry.png"));
```
