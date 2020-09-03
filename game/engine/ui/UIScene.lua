require("engine/utils/OOP");
local GFXConfig = require("engine/graphics/GFXConfig");
local Widget = require("engine/ui/bricks/elements/Widget");
local Scene = require("engine/Scene");

local UIScene = Class("UIScene", Scene);

UIScene.init = function(self, widget)
	assert(widget);
	assert(widget:isInstanceOf(Widget));
	self._widget = widget;
end

UIScene.update = function(self, dt)
	self._widget:update(dt);
	local width, height = GFXConfig:getNativeSize();
	self._widget:setLocalPosition(0, width, 0, height);
	self._widget:layout();
end

UIScene.draw = function(self)
	self._widget:draw();
end

return UIScene;
