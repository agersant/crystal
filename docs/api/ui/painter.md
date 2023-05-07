---
parent: crystal.ui
grand_parent: API Reference
nav_order: 2
---

# crystal.Painter

A [Wrapper](wrapper) which applies a shader when drawing its child. This element draws in two passes:

1. Its descendents are rendered to an offscreen [canvas](https://love2d.org/wiki/Canvas).
2. The resulting canvas is drawn to the screen with the desired [shader](https://love2d.org/wiki/Shader) applied.

If no shader is set on this element, it draws in a single pass (skipping the intermediate canvas).

The child of a `Painter` has a [Basic Joint](basic_joint) to adjust positioning preferences (padding, alignment, etc.).

[RoundedCorners](rounded_corners) is an example of a `Painter` element.

## Constructor

```lua
crystal.Painter:new(shader)
```

The optional `shader` parameter should be a [love.Shader](https://love2d.org/wiki/Shader).

## Methods

| Name                             | Description                                           |
| :------------------------------- | :---------------------------------------------------- |
| [set_shader](painter_set_shader) | Sets or clears the shader used to draw this element.  |
| [shader](painter_shader)         | Returns the shader used to draw this element, if any. |

## Callbacks

| Name                                         | Description                               |
| :------------------------------------------- | :---------------------------------------- |
| [configure_shader](painter_configure_shader) | Called right before the element is drawn. |

## Examples

This example illustrates what implementing your own `Painter` class looks like:

```lua
local MyPainter = Class("MyPainter", crystal.Painter);

MyPainter.init = function(self)
  MyPainter.super.init(self, crystal.assets.get("assets/my_shader.glsl"));
  self.my_param = 0;
end

MyPainter.set_param = function(self, value)
  self.my_param = value;
end

MyPainter.configure_shader = function(self, shader, quad)
  shader:send("my_param", self.my_param);
end
```
