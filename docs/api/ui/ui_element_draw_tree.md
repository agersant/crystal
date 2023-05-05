---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:draw_tree

Draws this element and all its descendants.

This function also keeps track of where it draws elements that can interact with the mouse, so that the mouse target can be accurately updated on the next frame.

{: .warning}
This method can only be called on elements that have no parent.

## Usage

```lua
ui_element:draw_tree()
```

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
