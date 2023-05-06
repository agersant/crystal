---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:is_mouse_over

Returns whether this element is the current mouse target.

{: .note}
The data returned by this function is updated at the start of each [update_tree](ui_element_update_tree) call.

## Usage

```lua
ui_element:is_mouse_over()
```

## Returns

| Name   | Type      | Description                                                                                                   |
| :----- | :-------- | :------------------------------------------------------------------------------------------------------------ |
| `over` | `boolean` | True if this element is the current [mouse target](/crystal/api/input/current_mouse_target), false otherwise. |

## Examples

This example defines a scene which constantly prints whether a specific image is the current mouse target:

```lua
local MyScene = Class("MyScene", crystal.Scene);

MyScene.init = function(self)
  self.list = crystal.VerticalList:new();
  self.sword = self.list:add_child(crystal.Image:new(crystal.assets.get("assets/sword.png")));
  self.shield = self.list:add_child(crystal.Image:new(crystal.assets.get("assets/shield.png")));
end

MyScene.update = function(self, dt)
  self.list:update_tree(dt);
  print(self.sword:is_mouse_over());
end

MyScene.draw = function(self)
  self.list:draw_tree();
end
```
