local Scene = require("modules/scene/scene");
local Widget = require("ui/bricks/elements/Widget");

---@class UIScene : Scene
local UIScene = Class("UIScene", Scene);

UIScene.init = function(self, widget)
	assert(widget);
	assert(widget:inherits_from(Widget));
	self.widget = widget;
end

---@param dt number
UIScene.update = function(self, dt)
	local width, height = crystal.window.viewport_size();
	self.widget:updateTree(dt, width, height);
end

UIScene.draw = function(self)
	self.widget:draw();
end

return UIScene;
