---
parent: crystal.scene
grand_parent: API Reference
nav_exclude: true
---

# Transition:draw

Draws the transition. This method is meant to be overridden.

## Usage

```lua
transition:draw()
```

### Arguments

| Name          | Type       | Description                                                                          |
| :------------ | :--------- | :----------------------------------------------------------------------------------- |
| `progress`    | `number`   | A number between 0 and 1 describing current progress through the transition.         |
| `width`       | `number`   | Width of the area to cover with the transition, in pixels. Usually viewport width.   |
| `height`      | `number`   | Height of the area to cover with the transition, in pixels. Usually viewport height. |
| `draw_before` | `function` | Function with no arguments drawing the scene being transitioned from.                |
| `draw_after`  | `function` | Function with no arguments drawing the scene being transitioned to.                  |

## Examples

```lua
local CrossFade = Class("CrossFade", crystal.Transition);
CrossFade.draw = function(self, progress, width, height, draw_before, draw_after)
  draw_before();
  love.graphics.setColor(crystal.Color.white:alpha(progress));
  draw_after();
end
```
