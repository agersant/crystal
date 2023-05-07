---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Painter:configure_shader

Called right before the element is drawn. This callback is often used to [send](https://love2d.org/wiki/Shader:send) uniform variables to the shader.

## Usage

```lua
painter.configure_shader = function(self, shader, quad)
end
```

### Arguments

| Name     | Type                                          | Description                                                          |
| :------- | :-------------------------------------------- | :------------------------------------------------------------------- |
| `shader` | [love.Shader](https://love2d.org/wiki/Shader) | Shader used by this painter (same as `painter:shader()`).            |
| `quad`   | [love.Quad](https://love2d.org/wiki/Quad)     | Quad describing the region being drawn from the intermediate canvas. |

## Examples

This example is from the [RoundedCorners](rounded_corners) implementation:

```lua
RoundedCorners.configure_shader = function(self, shader, quad)
  local radii = { self.radius_top_left, self.radius_top_right, self.radius_bottom_right, self.radius_bottom_left };
  shader:send("radii", radii);
  shader:send("draw_size", { self:size() });
  shader:send("texture_size", { quad:getTextureDimensions() });
end
```
