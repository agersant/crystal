---
parent: crystal.graphics
grand_parent: API Reference
---

# crystal.DrawEffect

A [Component](/crystal/api/ecs/component) that can affect how [drawables](/crystal/api/graphics/drawable) on this entity are drawn.

When a [DrawSystem](draw_system) is drawing, it surrounds each `Drawable:draw()` with calls to `pre_draw()` and `post_draw()` on the entities' DrawEffect components. The order in which the draw effects are applied is unspecified.

This class is only useful when overriding `pre_draw()` and/or `post_draw()`, as the default implementations are blank. An example usage of this component would be to use `pre_draw()` to call `love.graphics.setShader`(https://love2d.org/wiki/love.graphics.setShader), in order to apply a visual effect to an entity.

## Constructor

Like all other components, `DrawEffect` components are created by calling [Entity:add_component](/crystal/api/ecs/entity_add_component).

The constructor for DrawEffect expects no arguments.

## Methods

| Name      | Description |
| :-------- | :---------- |
| post_draw |             |
| pre_draw  |             |

## Examples

```lua

```
