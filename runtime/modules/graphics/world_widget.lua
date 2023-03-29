local Drawable = require("modules/graphics/drawable");

---@class WorldWidget : Drawable
---@field private widget Widget
local WorldWidget = Class("WorldWidget", Drawable);

WorldWidget.init = function(self, widget)
	assert(widget:inherits_from("Element"));
	WorldWidget.super.init(self);
	self.widget = widget;
end

---@param dt number
WorldWidget.update_widget = function(self, dt)
	self.widget:updateTree(dt);
end

WorldWidget.draw = function(self)
	local width, height = self.widget:getSize();
	local x = math.round(-width / 2);
	local y = math.round(-height / 2);
	love.graphics.translate(x, y);
	self.widget:draw();
end

--#region Tests

local Image = require("ui/bricks/elements/Image");

crystal.test.add("Can draw world widget", function(context)
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty.lua");
	local entity = scene:spawn(crystal.Entity);
	local widget = Image:new();
	widget:setImageSize(48, 32);
	entity:add_component(crystal.Body);
	entity:add_component(crystal.WorldWidget, widget);
	entity:set_position(160, 120);

	scene:update(0);
	scene:draw();
	context:expect_frame("test-data/TestWorldWidget/draws-widget.png");
end);

--#endregion

return WorldWidget;
