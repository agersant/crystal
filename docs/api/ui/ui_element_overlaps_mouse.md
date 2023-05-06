---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:overlaps_mouse

Advanced
{: .label .label-yellow}

Returns whether this element can become the mouse target, given a specific player index and mouse position.

You may override this method to implement hoverable/clickable elements that have non rectangular hitboxes.

## Usage

```lua
ui_element:overlaps_mouse(player_index, mouse_x, mouse_y)
```

### Arguments

| Name           | Type     | Description                                                                                     |
| :------------- | :------- | :---------------------------------------------------------------------------------------------- |
| `player_index` | `number` | Number identifying the player controlling the mouse.                                            |
| `mouse_x`      | `number` | Mouse x position from [love.mouse.getPosition](https://love2d.org/wiki/love.mouse.getPosition). |
| `mouse_y`      | `number` | Mouse y position from [love.mouse.getPosition](https://love2d.org/wiki/love.mouse.getPosition). |

### Returns

| Name       | Type      | Description                                                       |
| :--------- | :-------- | :---------------------------------------------------------------- |
| `overlaps` | `boolean` | True if the element can become the mouse target, false otherwise. |

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
