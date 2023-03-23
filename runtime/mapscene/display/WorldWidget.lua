local Drawable = require("mapscene/display/Drawable");

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
		self._widget:updateTree(dt);
	end
end

WorldWidget.draw = function(self)
	WorldWidget.super.draw(self);
	if self._widget then
		local width, height = self._widget:getSize();
		local x = math.round(self._x - width / 2);
		local y = math.round(self._y - height / 2);
		love.graphics.push("all");
		love.graphics.translate(x, y);
		self._widget:draw();
		love.graphics.pop();
	end
end

--#region Tests

local Image = require("ui/bricks/elements/Image");

crystal.test.add("Draws widget", function(context)
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty.lua");
	local entity = scene:spawn(crystal.Entity);
	local widget = Image:new();
	widget:setImageSize(48, 32);
	entity:add_component(crystal.Body, "dynamic");
	entity:add_component(WorldWidget, widget);
	entity:set_position(160, 120);

	scene:update(0);
	scene:draw();
	context:expect_frame("test-data/TestWorldWidget/draws-widget.png");
end);

--#endregion

return WorldWidget;
