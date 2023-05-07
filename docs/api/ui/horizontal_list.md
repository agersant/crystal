---
parent: crystal.ui
grand_parent: API Reference
nav_order: 2
---

# crystal.HorizontalList

A [Container](container) which positions its children in a row.

Children of a horizontal list have [HorizontalList Joints](horizontal_list_joint) associated with them to adjust positioning preferences (padding, alignment, etc.).

## Constructor

```lua
crystal.HorizontalList:new()
```

## Examples

This example defines a scene which draws a list of icons:

```lua
local MyScene = Class("MyScene", crystal.Scene);

MyScene.init = function(self)
  self.list = crystal.HorizontalList:new();
  self.list:add_child(crystal.Image:new(crystal.assets.get("assets/sword.png")));
  self.list:add_child(crystal.Image:new(crystal.assets.get("assets/shield.png")));
  self.list:add_child(crystal.Image:new(crystal.assets.get("assets/helmet.png")));
end

MyScene.update = function(self, dt)
  self.list:update_tree(dt);
end

MyScene.draw = function(self)
  self.list:draw_tree();
end
```
