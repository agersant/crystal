require("engine/utils/OOP");
local Drawable = require("engine/mapscene/display/Drawable");
local MathUtils = require("engine/utils/MathUtils");

local WorldWidget = Class("WorldWidget", Drawable);

WorldWidget.init = function(self, widget)
	WorldWidget.super.init(self);
	self._widget = widget;
	self._x = 0;
	self._y = 0;
end

WorldWidget.setWidgetPosition = function(self, x, y)
	assert(x);
	assert(y);
	self._x = x;
	self._y = y;
end

WorldWidget.updateWidget = function(self, dt)
	if self._widget then
		self._widget:update(dt);
		local width, height = self._widget:getDesiredSize();
		self._widget:setLocalPosition(0, width, 0, height);
		self._widget:layout();
	end
end

WorldWidget.draw = function(self)
	WorldWidget.super.draw();
	if self._widget then
		local width, height = self._widget:getSize();
		local x = MathUtils.round(self._x - width / 2);
		local y = MathUtils.round(self._y - height / 2);
		love.graphics.push("all");
		love.graphics.translate(x, y);
		self._widget:draw();
		love.graphics.pop();
	end
end

return WorldWidget;
