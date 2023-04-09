local Widget = require("ui/bricks/elements/Widget");
local Scene = require("Scene");

local UIScene = Class("UIScene", Scene);

UIScene.init = function(self, widget)
	UIScene.super.init(self);
	assert(widget);
	assert(widget:inherits_from(Widget));
	self._widget = widget;
	self:update(0);
end

UIScene.update = function(self, dt)
	local width, height = crystal.window.viewport_size();
	self._widget:updateTree(dt, width, height);
end

UIScene.draw = function(self)
	crystal.window.draw_upscaled(function()
		self._widget:draw();
	end);
end

return UIScene;
