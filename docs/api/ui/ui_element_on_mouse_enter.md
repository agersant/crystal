---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:on_mouse_enter

Called when this element or one of its descendents becomes the mouse target.

## Usage

```lua
ui_element.on_mouse_enter = function(self, player_index)
  -- your code here
end
```

### Arguments

| Name           | Type     | Description                                                                             |
| :------------- | :------- | :-------------------------------------------------------------------------------------- |
| `player_index` | `number` | Number identifying the [player](/crystal/api/input/input_player) controlling the mouse. |

## Examples

This example defines a scene which prints a message whenever the mouse cursor gets inside or away from a list of images:

```lua
local MyScene = Class("MyScene", crystal.Scene);

MyScene.init = function(self)
  self.list = crystal.VerticalList:new();
  local sword = self.list:add_child(crystal.Image:new(crystal.assets.get("assets/sword.png")));
  local shield = self.list:add_child(crystal.Image:new(crystal.assets.get("assets/shield.png")));

  self.list.on_mouse_enter = function(self, player_index)
    print("list.on_mouse_enter");
  end

  self.list.on_mouse_leave = function(self, player_index)
    print("list.on_mouse_leave");
  end
end

MyScene.update = function(self, dt)
  self.list:update_tree(dt);
end

MyScene.draw = function(self)
  self.list:draw_tree();
end

MyScene.mouse_moved = function(self, x, y, dx, dy, is_touch)
  self.list:update_mouse_target();
end
```
