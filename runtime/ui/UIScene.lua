local Renderer = require("graphics/Renderer");
local Widget = require("ui/bricks/elements/Widget");
local Scene = require("Scene");

local UIScene = Class("UIScene", Scene);

UIScene.init = function(self, widget)
	UIScene.super.init(self);
	self._renderer = Renderer:new(VIEWPORT);
	assert(widget);
	assert(widget:isInstanceOf(Widget));
	self._widget = widget;
	self:update(0);
end

UIScene.update = function(self, dt)
	local width, height = self._renderer:getViewport():getRenderSize();
	self._widget:updateTree(dt, width, height);
end

UIScene.draw = function(self)
	self._renderer:draw(function()
		self._widget:draw();
	end);
end

return UIScene;
