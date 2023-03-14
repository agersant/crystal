---
parent: crystal.tool
grand_parent: API Reference
---

# crystal.Tool

Base class for tools to inherit from.

## Methods

| Name         | Description                                    |
| :----------- | :--------------------------------------------- |
| `is_visible` | Returns whether the tool is currently visible. |

## Callbacks

| Name          | Description                                                                                                                                                  |
| :------------ | :----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `draw`        | Called every frame while the tool is visible. Default implementation does nothing.                                                                           |
| `hide`        | Called when the tool stops being visible. Default implementation does nothing.                                                                               |
| `key_pressed` | Called when the tool receives a key press. Arguments after `self` are the same as those of [love.keypressed](https://love2d.org/wiki/love.keypressed).       |
| `text_input`  | Called when the tool receives text input. Arguments after `self` are the same as those of [love.textinput](https://love2d.org/wiki/love.textinput).          |
| `show`        | Called when the tool becomes visible. Default implementation does nothing.                                                                                   |
| `update`      | Called every frame. Default implementation does nothing. Arguments after `self` are the same as those of [love.update](https://love2d.org/wiki/love.update). |

## Examples

```lua
local MyTool = Class("MyTool", crystal.Tool);

MyTool.update = function(self, dt)
  -- do something every frame
end

MyTool.draw = function(self)
  assert(self:is_visible());
  -- draw something to the screen
end

MyTool.text_input = function(self, text)
  -- handle text input
end

MyTool.key_pressed = function(self, key, scan_code, is_repeat)
  -- handle key press
end

MyTool.show = function(self)
  -- do something when tool starts drawing
end

MyTool.hide = function(self)
  -- do something when tool stops drawing
end
```
