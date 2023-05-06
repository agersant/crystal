---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:is_mouse_inside

Returns whether the mouse target is an element inside this one (or itself).

{: .note}
The data returned by this function is updated at the start of each [update_tree](ui_element_update_tree) call.

## Usage

```lua
ui_element:is_mouse_inside()
```

## Returns

| Name     | Type      | Description                                                                                                                   |
| :------- | :-------- | :---------------------------------------------------------------------------------------------------------------------------- |
| `inside` | `boolean` | True if the current [mouse target](/crystal/api/input/current_mouse_target) is a descendent of this element, false otherwise. |

## Examples

This example defines a scene which constantly prints whether the mouse is inside a list of images:

```lua
local MyScene = Class("MyScene", crystal.Scene);

MyScene.init = function(self)
  self.list = crystal.VerticalList:new();
  self.sword = self.list:add_child(crystal.Image:new(crystal.assets.get("assets/sword.png")));
  self.shield = self.list:add_child(crystal.Image:new(crystal.assets.get("assets/shield.png")));
end

MyScene.update = function(self, dt)
  self.list:update_tree(dt);
  print(self.list:is_mouse_inside());
end

MyScene.draw = function(self)
  self.list:draw_tree();
end
```
