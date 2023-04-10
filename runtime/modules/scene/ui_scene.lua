local Scene = require("modules/scene/scene");
local Widget = require("ui/bricks/elements/Widget");

---@class UIScene : Scene
local UIScene = Class("UIScene", Scene);

UIScene.init = function(self, widget)
	UIScene.super.init(self);
	assert(widget);
	assert(widget:inherits_from(Widget));
	self.widget = widget;
	self:update(0);
end

---@param dt number
UIScene.update = function(self, dt)
	local width, height = crystal.window.viewport_size();
	self.widget:updateTree(dt, width, height);
end

UIScene.draw = function(self)
	crystal.window.draw_upscaled(function()
		self.widget:draw();
	end);
end

return UIScene;
