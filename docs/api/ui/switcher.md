---
parent: crystal.ui
grand_parent: API Reference
nav_order: 2
---

# crystal.Switcher

A [Container](container) which draws only one of its children at a time.

Chilren of a `Switcher` have a [Basic Joint](basic_joint) to adjust positioning preferences (padding, alignment, etc.).

## Constructor

```lua
crystal.Switcher:new()
```

## Methods

| Name                                        | Description                                             |
| :------------------------------------------ | :------------------------------------------------------ |
| [active_child](switcher_active_child)       | Returns which of its children this switcher is drawing. |
| [set_sizing_mode](switcher_set_sizing_mode) | Sets how this switcher's desired size is computed.      |
| [sizing_mode](switcher_sizing_mode)         | Returns how this switcher's desired size is computed.   |
| [switch_to](switcher_switch_to)             | Changes which of its children this switcher is drawing. |

## Examples

This example implements an image carousel that can be controlled with the arrow keys (assuming they are bound to the `"ui_left"` and `"ui_right"` [input actions](/crystal/api/input/set_bindings)):

```lua
local Carousel = Class("Carousel", crystal.Widget);

Carousel.init = function(self, images)
  Carousel.super.init(self);
  local switcher = self:set_child(crystal.Switcher:new());
  for _, image in ipairs(images) do
    switcher:add_child(crystal.Image:new(crystal.assets.get(image)));
  end

  local advance = function(delta, transition)
    local children = switcher:children();
    local index = table.index_of(children, switcher:active_child());
    index = index + delta;
    if index > #children then
      index = 1;
    elseif index < 1 then
      index = #children;
    end
    switcher:switch_to(switcher:child(index), transition);
  end

  switcher:bind_input("+ui_right", "always", nil, function()
    advance(1, crystal.Transition.ScrollLeft:new())
  end);

  switcher:bind_input("+ui_left", "always", nil, function()
    advance(-1, crystal.Transition.ScrollRight:new())
  end);
end

-- usage: local carousel = Carousel:new({ "cool_image.png", "other_image.png", "last_image.png" });
```
