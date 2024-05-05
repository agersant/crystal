---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:update_tree

Computes layout and runs update logic for this element and all its descendants. You should call this once per frame on the root of each UI element tree your game uses.

The outline of everything happening within this call is:

1. [UIElement:update](ui_element_update) is called on every element inside this tree. Notably, this ticks all [scripts](/crystal/api/script/script) owned by [Widget](widget) elements.
2. The element tree is traversed again so every element can compute its desired size ([compute_desired_size](ui_element_compute_desired_size) is called on every element).
3. The element tree is traversed one last time to assign each element its actual size ([set_relative_position](ui_element_set_relative_position) is called on every element).

{: .warning}
This method can only be called on elements that have no parent.

## Usage

```lua
ui_element:update_tree(delta_time)
```

### Arguments

| Name         | Type     | Description            |
| :----------- | :------- | :--------------------- |
| `delta_time` | `number` | Delta time in seconds. |

When calling this variant, without explicit `width` and `height` arguments, the element will be sized to its desired size.

## Usage

```lua
ui_element:update_tree(delta_time, width, height)
```

### Arguments

| Name         | Type     | Description                                        |
| :----------- | :------- | :------------------------------------------------- |
| `delta_time` | `number` | Delta time in seconds.                             |
| `width`      | `number` | Available width for the widget layout, in pixels.  |
| `height`     | `number` | Available height for the widget layout, in pixels. |

## Examples

This example defines a scene drawing a UI tree that covers the whole screen:

```lua
local TitleScreenUI = Class("TitleScreenUI", crystal.Overlay);

TitleScreenUI.init = function(self)
  TitleScreenUI.super.init(self);
  local text = self:add_child(crystal.Text:new());
  text:set_text("Legend of Sword");
  text:set_alignment("center", "center");
end

local TitleScreenScene = Class("TitleScreenScene", crystal.Scene);

TitleScreenScene.init = function(self)
  self.ui = TitleScreenUI:new();
end

TitleScreenScene.update = function(self, dt)
  local width, height = crystal.window.viewport_size();
  self.ui:update_tree(dt, width, height);
end

TitleScreenScene.draw = function(self)
  self.ui:draw_tree();
end

crystal.scene.replace(TitleScreenScene:new());
```
