---
parent: crystal.window
grand_parent: API Reference
nav_order: 1
---

# crystal.window.draw

Draws on the screen with scaling and letterboxing transforms applied. This function relies on [love.graphics.scale](https://love2d.org/wiki/love.graphics.scale) to upscale visuals from the viewport size to the window size.

Since LOVE point size is unaffected by scale transforms, you can multiply values by the [viewport scale](viewport_scale) when [setting point sizes](https://love2d.org/wiki/love.graphics.setPointSize).

{: .note}
When a [Scene](/crystal/api/scene/scene) is drawing on the screen, its draw method is already wrapped by `crystal.window.draw`. This means you rarely (if ever) need to call this function yourself.

## Usage

```lua
crystal.window.draw(draw_function);
```

### Arguments

| Name   | Type       | Description                            |
| :----- | :--------- | :------------------------------------- |
| `draw` | `function` | Function containing the drawing logic. |

## Examples

```lua
crystal.window.draw(function()
  love.graphics.circle("fill", 50, 50, 40);
end);
```
