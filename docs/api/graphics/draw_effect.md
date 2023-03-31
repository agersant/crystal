---
parent: crystal.graphics
grand_parent: API Reference
---

# crystal.DrawEffect

A [Component](/crystal/api/ecs/component) that can affect how [drawables](drawable) on this entity are drawn.

[DrawSystem](draw_system) surrounds each `Drawable:draw()` with calls to `pre_draw()` and `post_draw()` on entities' DrawEffect components. The order in which the draw effects are applied for each Drawable component is unspecified.

{: .note}
This class is only useful when overriding `pre_draw()` and/or `post_draw()`, as the default implementations are blank. An example usage of this component would be to use `pre_draw()` to call `love.graphics.setShader`(https://love2d.org/wiki/love.graphics.setShader), in order to apply a visual effect to an entity.

## Constructor

Like all other components, DrawEffect components are created by calling [Entity:add_component](/crystal/api/ecs/entity_add_component).

The constructor for DrawEffect expects no arguments.

## Methods

| Name        | Description                                                                                                |
| :---------- | :--------------------------------------------------------------------------------------------------------- |
| `post_draw` | Method called before drawing [Drawable](drawable) components on this entity. Base implementation is empty. |
| `pre_draw`  | Method called after drawing [Drawable](drawable) components on this entity. Base implementation is empty.  |

## Examples

This example defines a component which offsets entities vertically to simulate altitude in a top-down 2D game.

```lua
local Altitude = Class("Altitude", crystal.DrawEffect);

Altitude.init = function(self, altitude)
  self.altitude = altitude;
end

Altitude.pre_draw = function(self)
  love.graphics.translate(0, -self.altitude);
end
```
