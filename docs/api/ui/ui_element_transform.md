---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:transform

Advanced
{: .label .label-yellow}

Returns the global [Transform](https://love2d.org/wiki/Transform) in use last time this element was drawn.

You may use this function while implementing [overlaps_mouse](ui_element_overlaps_mouse) for custom elements.

This function will error if the element has not been drawn yet.

## Usage

```lua
ui_element:transform()
```

### Returns

| Name             | Type                                                | Description                                 |
| :--------------- | :-------------------------------------------------- | :------------------------------------------ |
| `last_transform` | [love.Transform](https://love2d.org/wiki/Transform) | Global transform used to draw this element. |

## Examples

This example implements an element type which draws a circle and accurately triggers [on_mouse_over](ui_element_on_mouse_over) callbacks:

```lua
local Circle = Class("Circle", crystal.Element);

Circle.init = function(self, radius)
  self.radius = radius;
  self:enable_mouse();
end

Circle.compute_desired_size = function(self)
  return 2 * self.radius, 2 * self.radius;
end

Circle.draw_self = function(self)
  local w, h = self:size();
  local effective_radius = math.min(w / 2, h / 2);
  love.graphics.circle("fill", w / 2, h / 2, effective_radius);
end

Circle.overlaps_mouse = function(self, player_index, mouse_x, mouse_y)
  if not Circle.super.overlaps_mouse(self, player_index, mouse_x, mouse_y) then
    return false;
  end
  local w, h = self:size();
  local effective_radius = math.min(w / 2, h / 2);
  local center = self:transform():transformPoint(w / 2, h / 2);
  return math.distance(w / 2, h / 2, mouse_x, mouse_y) <= effective_radius;
end
```
