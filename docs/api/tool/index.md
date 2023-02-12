---
parent: API Reference
has_children: true
has_toc: false
---

# crystal.tool

This module facilitates the implementation of development tools, like performance monitors, entity inspectors, or other debug overlays.

All tools should inherit from the globally available [crystal.Tool](tool) class. Tool classes can override methods (like `update` and `draw`) from the base class.

Some common tools are already implemented by Crystal. Please refer to the [Built-in Tools](/tools) page for more details.

{: .warning }
Tools are intended for development functionality and are not available in [fused builds](https://love2d.org/wiki/love.filesystem.isFused).

The example below implements a tool counting the number of frames elapsed so far in the game. This tool can be toggled by pressing `F1` on the keyboard:

```lua
local FrameCounter = Class("FrameCounter", crystal.Tool);

FrameCounter.init = function(self)
	self.num_frames = 0;
end

FrameCounter.update = function(self, dt)
	self.num_frames = self.num_frames + 1;
end

FrameCounter.draw = function(self)
	love.graphics.print(self.num_frames, 10, 10)
end

crystal.tool.add(FrameCounter:new(), { keybind = "f1" });
```

## Functions

| Name                                  | Description                                  |
| :------------------------------------ | :------------------------------------------- |
| [crystal.tool.add](add)               | Defines a new tool                           |
| [crystal.tool.hide](hide)             | Makes a tool no longer draw on the screen.   |
| [crystal.tool.is_visible](is_visible) | Returns whether a tool is currently visible. |
| [crystal.tool.show](show)             | Makes a tool draw on the screen.             |

## Classes

| Name                 | Description                           |
| :------------------- | :------------------------------------ |
| [crystal.Tool](tool) | Base class for tools to inherit from. |
