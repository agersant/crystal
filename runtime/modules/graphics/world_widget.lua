local Drawable = require("modules/graphics/drawable");

---@class WorldWidget : Drawable
---@field private widget Widget
---@field private anchor_x number
---@field private anchor_y number
local WorldWidget = Class("WorldWidget", Drawable);

WorldWidget.init = function(self, widget)
	assert(widget == nil or widget:inherits_from("UIElement"));
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

---@param widget UIElement
WorldWidget.set_widget = function(self, widget)
	assert(widget == nil or widget:inherits_from("UIElement"));
	self.widget = widget;
end

---@param dt number
WorldWidget.update_widget = function(self, dt)
	if self.widget then
		self.widget:update_tree(dt);
	end
end

WorldWidget.draw = function(self)
	if not self.widget then
		return;
	end
	local width, height = self.widget:size();
	local x = math.round(-width * self.anchor_x);
	local y = math.round(-height * self.anchor_y);
	love.graphics.translate(x, y);
	self.widget:draw();
end

--#region Tests

local TestWorld = Class:test("TestWorld");

TestWorld.init = function(self)
	self.ecs = crystal.ECS:new();
	self.draw_system = self.ecs:add_system(crystal.DrawSystem);
	self.physics_system = self.ecs:add_system(crystal.PhysicsSystem);
end

TestWorld.update = function(self, dt)
	self.ecs:update(dt);
	self.physics_system:simulate_physics(dt);
	self.draw_system:update_drawables(dt);
end

TestWorld.draw = function(self)
	self.draw_system:draw_entities();
end

crystal.test.add("Can draw world widget", { resolution = { 200, 200 } }, function(context)
	local world = TestWorld:new();
	local entity = world.ecs:spawn(crystal.Entity);
	local widget = crystal.Image:new();
	widget:set_image_size(48, 32);
	entity:add_component(crystal.Body);
	entity:add_component(crystal.WorldWidget, widget);
	entity:set_position(100, 100);

	world:update(0);
	world:draw();
	context:expect_frame("test-data/draws-widget.png");
end);

crystal.test.add("Can adjust widget anchors", { resolution = { 200, 200 } }, function(context)
	local world = TestWorld:new();
	local entity = world.ecs:spawn(crystal.Entity);
	local widget = crystal.Image:new();
	widget:set_image_size(48, 32);
	entity:add_component(crystal.Body);
	entity:add_component(crystal.WorldWidget, widget);
	entity:set_widget_anchor(0, 0);
	entity:set_position(100, 100);

	world:update(0);
	world:draw();
	context:expect_frame("test-data/can-adjust-widget-anchors.png");
end);

--#endregion

return WorldWidget;
