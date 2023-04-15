---
parent: crystal.window
grand_parent: API Reference
nav_order: 1
---

# crystal.window.draw_native

Draws on a viewport-sized canvas, and then draws the canvas on the screen. Canvas used by this function have their filtering mode set to `"nearest"`, which makes them suitable to draw pixel-art games at native size.

{: .warning}
Nested calls to this function use distinct canvas. As a result, this function may allocate a canvas. Previously used canvas are re-used when possible so allocations should be very rare.

## Usage

```lua
crystal.window.draw_native(draw_function);
```

### Arguments

| Name          | Type       | Description                            |
| :------------ | :--------- | :------------------------------------- |
| `draw_native` | `function` | Function containing the drawing logic. |

## Examples

```lua
MyScene.draw = function(self)
  crystal.window.draw_native(function()
    self.draw_system:draw_entities();
  end);
  self.ecs:notify_systems("draw_debug");
end
```
