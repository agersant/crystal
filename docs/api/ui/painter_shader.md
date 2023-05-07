---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Painter:shader

Returns the shader used to draw this element, if any.

## Usage

```lua
painter:shader(shader)
```

### Returns

| Name     | Type                                                   | Description                       |
| :------- | :----------------------------------------------------- | :-------------------------------- |
| `shader` | [love.Shader](https://love2d.org/wiki/Shader) \| `nil` | Shader used to draw this element. |

## Examples

```lua
local shader = crystal.assets.get("cool_shader.glsl");
local my_painter = crystal.Painter:new();
my_painter:set_shader(shader);
assert(my_painter:shader() == shader);
```
