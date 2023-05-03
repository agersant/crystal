---
parent: crystal.window
grand_parent: API Reference
nav_order: 1
---

# crystal.window.transform

Returns the current transformation stack maintained by `love.graphics`, ignoring resets performed within [draw_via_canvas](draw_via_canvas).

## Usage

```lua
crystal.window.transform();
```

### Arguments

| Name        | Type                                                | Description                  |
| :---------- | :-------------------------------------------------- | :--------------------------- |
| `transform` | [love.Transform](https://love2d.org/wiki/Transform) | Active transformation stack. |

## Examples

```lua
love.graphics.translate(100, 50);
print(crystal.window.transform():transformPoint(0, 0)); -- Prints 100, 50

local canvas = love.graphics.newCanvas();
crystal.window.draw_via_canvas(canvas,
  function()
    -- Here we can draw at (0, 0) to paint in the corner of the canvas, but
    -- `crystal.window.transform()` still reports the intended screen transform
    -- including the translation.
    print(crystal.window.transform():transformPoint(0, 0)); -- Prints 100, 50
  end,
  function()
    love.graphics.draw(canvas);
  end,
);
```
