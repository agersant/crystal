local Drawable = require("modules/graphics/drawable");

---@class WorldWidget : Drawable
---@field private widget Widget
---@field private anchor_x number
---@field private anchor_y number
local WorldWidget = Class("WorldWidget", Drawable);

WorldWidget.init = function(self, widget)
	assert(widget == nil or widget:inherits_from("Element"));
	WorldWidget.super.init(self);
	self.widget = widget;
	self.anchor_x = 0.5;
	self.anchor_y = 0.5;
end

---@param x number
---@param y number
WorldWidget.set_widget_anchor = function(self, x, y)
	assert(type(x) == "number");
	assert(type(y) == "number");
	self.anchor_x = x;
	self.anchor_y = y;
end

---@return widget
WorldWidget.widget = function(self)
	return self.widget;
end

---@param widget Element
WorldWidget.set_widget = function(self, widget)
	assert(widget == nil or widget:inherits_from("Element"));
	self.widget = widget;
end

---@param dt number
WorldWidget.update_widget = function(self, dt)
	if self.widget then
		self.widget:updateTree(dt);
	end
end

WorldWidget.draw = function(self)
	if not self.widget then
		return;
	end
	local width, height = self.widget:getSize();
	local x = math.round(-width * self.anchor_x);
	local y = math.round(-height * self.anchor_y);
	love.graphics.translate(x, y);
	self.widget:draw();
end

--#region Tests

local Image = require("ui/bricks/elements/Image");

crystal.test.add("Can draw world widget", function(context)
	local world = crystal.World:new("test-data/empty.lua");
	local entity = world:spawn(crystal.Entity);
	local widget = Image:new();
	widget:setImageSize(48, 32);
	entity:add_component(crystal.Body);
	entity:add_component(crystal.WorldWidget, widget);
	entity:set_position(160, 120);

	world:update(0);
	world:draw();
	context:expect_frame("test-data/TestWorldWidget/draws-widget.png");
end);

crystal.test.add("Can adjust widget anchors", function(context)
	local world = crystal.World:new("test-data/empty.lua");
	local entity = world:spawn(crystal.Entity);
	local widget = Image:new();
	widget:setImageSize(48, 32);
	entity:add_component(crystal.Body);
	entity:add_component(crystal.WorldWidget, widget);
	entity:set_widget_anchor(0, 0);
	entity:set_position(160, 120);

	world:update(0);
	world:draw();
	context:expect_frame("test-data/TestWorldWidget/can-adjust-widget-anchors.png");
end);

--#endregion

return WorldWidget;
