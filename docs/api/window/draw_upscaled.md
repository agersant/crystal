---
parent: crystal.window
grand_parent: API Reference
nav_order: 1
---

# crystal.window.draw_upscaled

Draws on a native-height canvas, then applies scaling and letterboxing transforms.

## Usage

```lua
crystal.window.draw_upscaled(draw_function);
```

### Arguments

| Name            | Type       | Description                            |
| :-------------- | :--------- | :------------------------------------- |
| `draw_function` | `function` | Function containing the drawing logic. |

## Examples

```lua
crystal.window.draw_upscaled(function()
  love.graphics.circle("fill", 50, 50, 40);
end);
```

```lua
MyScene.draw = function(self)
  crystal.window.draw_upscaled(function()
    -- Draw game world and characters
  end);
end
```
