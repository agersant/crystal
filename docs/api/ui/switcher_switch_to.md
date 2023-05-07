---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Switcher:switch_to

Changes which of its children this switcher is drawing. This function can be used with zero or more [transitions](transition) which play in a sequence.

If a transition is already in progress, it will snap to completion before this function operates.

This function will emit an error when trying to switch to an element that is not a child of the switcher. Trying to switch to a child that is already the active child does nothing.

## Usage

```lua
switcher:switch_to(child, ...)
```

### Arguments

| Name    | Type                                                | Description                                 |
| :------ | :-------------------------------------------------- | :------------------------------------------ |
| `child` | [crystal.UIElement](ui_element)                     | Child of this switcher to begin displaying. |
| `...`   | [crystal.Transition](/crystal/api/scene/transition) | Transitions to play.                        |

## Examples

This examples implements an image gallery widget which fades to a different image every time the player presses a key [bound](/crystal/api/input/input_player_set_bindings) to `"ui_ok"`.

```lua
local Gallery = Class("Gallery", crystal.Widget);

Gallery.init = function(self, images)
  Gallery.super.init(self);
  local switcher = self:set_child(crystal.Switcher:new());
  for _, image in ipairs(images) do
    switcher:add_child(crystal.Image:new(crystal.assets.get(image)));
  end

  local swap_image = function()
    local children = switcher:children();
    local index = math.random(1, #children);
    switcher:switch_to(switcher:child(index), crystal.Transition.FadeToBlack:new(), crystal.Transition.FadeFromBlack:new());
  end

  switcher:bind_input("+ui_ok", "always", nil, swap_image);
end

-- usage: local carousel = Carousel:new({ "cool_image.png", "other_image.png", "last_image.png" });
```
