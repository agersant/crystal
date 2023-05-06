---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:draw_self

Advanced
{: .label .label-yellow}

Draws this element and all its descendants.

This function is called within [draw_tree](ui_element_draw_tree), after the relevant transformations (layout, translation, scale, rotation) have been pushed on the LOVE graphics stack.

You may override this method to implement new element types that have their own way of drawing content (particles, splines, etc.).

If you override this method on a [Container](container) or [Wrapper](wrapper) element, make sure to call `:draw()`, not `:draw_self()`, on its children.

## Usage

```lua
ui_element:draw_self()
```

## Examples

This example is the implementation of `draw_self` for [Image](image) elements:

```lua
Image.draw_self = function(self)
  local w, h = self:size();
  if self._texture then
    love.graphics.draw(self._texture, 0, 0, w, h);
  else
    love.graphics.rectangle("fill", 0, 0, w, h);
  end
end
```

This example is the implementation of `draw_self` for [Switcher](switcher) elements:

```lua
Switcher.draw_self = function(self)
  if self.transition then
    local width, height = self:size();
    self.transition:draw(self.transition_progress, width, height, self.draw_previous, self.draw_active);
  else
    self._active_child:draw();
  end
end
```
