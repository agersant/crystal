---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:update_mouse_target

Executes mouse callbacks ([on_mouse_over](ui_element_on_mouse_over), [on_mouse_out](ui_element_on_mouse_out), etc.) on applicable elements within this tree.

{: .warning}
This method can only be called on elements that have no parent.

## Usage

```lua
ui_element:update_mouse_target()
```

## Examples

This example defines a scene drawing a UI tree that covers the whole screen:

```lua
local MyScene = Class("MyScene", crystal.Scene);

MyScene.init = function(self)
  self.ui = crystal.Image:new();
  self.ui.on_mouse_enter = function()
    print("Cursor overlapping the image!");
  end
end

MyScene.update = function(self, dt)
  self.ui:update_tree(dt, 100, 100);
end

MyScene.draw = function(self)
  self.ui:draw_tree();
end

MyScene.mouse_moved = function(self, x, y, dx, dy, is_touch)
  self.ui:update_mouse_target();
end
```
