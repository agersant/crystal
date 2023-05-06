---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:on_mouse_out

Called when this element is no longer the mouse target.

## Usage

```lua
ui_element.on_mouse_out = function(self, player_index)
  -- your code here
end
```

### Arguments

| Name           | Type     | Description                                                                             |
| :------------- | :------- | :-------------------------------------------------------------------------------------- |
| `player_index` | `number` | Number identifying the [player](/crystal/api/input/input_player) controlling the mouse. |

## Examples

This example defines a scene which prints a message whenever the mouse cursor gets on or off a sword image:

```lua
local MyScene = Class("MyScene", crystal.Scene);

MyScene.init = function(self)
  self.list = crystal.VerticalList:new();
  local sword = self.list:add_child(crystal.Image:new(crystal.assets.get("assets/sword.png")));
  local shield = self.list:add_child(crystal.Image:new(crystal.assets.get("assets/shield.png")));

  self.sword.on_mouse_over = function(self, player_index)
    print("sword.on_mouse_over");
  end

  self.sword.on_mouse_out = function(self, player_index)
    print("sword.on_mouse_out");
  end
end

MyScene.update = function(self, dt)
  self.list:update_tree(dt);
end

MyScene.draw = function(self)
  self.list:draw_tree();
end
```
