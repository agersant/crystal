require("engine/utils/OOP");
local GFXConfig = require("engine/graphics/GFXConfig");
local Renderer = require("engine/graphics/Renderer");
local Widget = require("engine/ui/bricks/elements/Widget");
local Scene = require("engine/Scene");

local UIScene = Class("UIScene", Scene);

UIScene.init = function(self, widget)
	UIScene.super.init(self);
	self._renderer = Renderer:new();
	assert(widget);
	assert(widget:isInstanceOf(Widget));
	self._widget = widget;
	self:update(0);
end

UIScene.update = function(self, dt)
	self._widget:update(dt);
	local width, height = GFXConfig:getRenderSize();
	self._widget:setLocalPosition(0, width, 0, height);
	self._widget:layout();
end

UIScene.draw = function(self)
	self._renderer:draw(function()
		self._widget:draw();
	end);
end

return UIScene;
