---
parent: crystal.window
grand_parent: API Reference
---

# crystal.window.draw_native

Draws on the screen with scaling and letterboxing transforms applied. This function relies on [love.graphics.scale](https://love2d.org/wiki/love.graphics.scale) to upscale visuals from the viewport size to the window size.

Since LOVE point size is unaffected by scale transforms, you can multiply values by the [viewport scale](viewport_scale) when [setting point sizes](https://love2d.org/wiki/love.graphics.setPointSize).

## Usage

```lua
crystal.window.draw_native(draw_function);
```

### Arguments

| Name            | Type       | Description                            |
| :-------------- | :--------- | :------------------------------------- |
| `draw_function` | `function` | Function containing the drawing logic. |

## Examples

```lua
crystal.window.draw_native(function()
  love.graphics.circle("fill", 50, 50, 40);
end);
```

```lua
MyScene.draw = function(self)
  crystal.window.draw_upscaled(function()
    self.my_ecs:notify_systems("draw_debug");
  end);
end
```
