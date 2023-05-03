---
parent: crystal.window
grand_parent: API Reference
nav_order: 1
---

# crystal.window.draw_via_canvas

Draws on a canvas, and then draws the canvas onto the screen. The transformation stack is [reset](https://love2d.org/wiki/love.graphics.reset) while drawing on the canvas, but internally preserved for the purpose of tracking areas that can be interacted with the mouse.

{: .note}
This function is used internally by [crystal.window.draw_native](draw_native) and by [Painter](/crystal/api/ui/painter) UI elements.

## Usage

```lua
crystal.window.draw_via_canvas(canvas, draw_function, blit_function);
```

### Arguments

| Name            | Type                                          | Description                                                   |
| :-------------- | :-------------------------------------------- | :------------------------------------------------------------ |
| `canvas`        | [love.Canvas](https://love2d.org/wiki/Canvas) | Canvas to draw onto.                                          |
| `draw_function` | `function`                                    | Function containing logic to draw the canvas onto the screen. |
| `blit_function` | `function`                                    | Function containing logic to draw the canvas onto the screen. |

## Examples

This example defines a scene where a post-processing effect is applied to the entire screen using a canvas.

```lua
MyScene = Class("MyScene", crystal.Scene);

MyScene.init = function(self)
  self.canvas = love.graphics.newCanvas();
  self.post_process = crystal.assets.get("crt_effect.glsl");
end

MyScene.draw = function(self)
  crystal.window.draw_via_canvas(
    self.canvas,
    function()
      -- Draw the game
    end,
    function()
      love.graphics.push("all");
      love.graphics.setShader(self.post_process);
      love.graphics.draw(self.canvas);
      love.graphics.pop();
    end,
  );
end
```

An incorrect implementation of the `draw` function is presented below. In this version, mouse interactions would not get detected correctly:

```lua
MyScene.draw = function(self)

  -- INCORRECT CODE - DO NOT COPY

  love.graphics.push("all");
  love.graphics.setCanvas(self.canvas);
  love.graphics.reset();
  -- Draw the game
  love.graphics.pop();

  love.graphics.push("all");
  love.graphics.setShader(self.post_process);
  love.graphics.draw(self.canvas);
  love.graphics.pop();
end
```
