require("engine/utils/OOP");
local Scene = require("engine/Scene");

local UIScene = Class("UIScene", Scene);

UIScene.init = function(self, widget)
	self._widget = widget;
end

UIScene.update = function(self, dt)
	self._widget:update(dt);
end

UIScene.draw = function(self)
	self._widget:draw();
end

return UIScene;
