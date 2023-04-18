local UIElement = require("modules/ui/ui_element");
local Image = require("ui/bricks/elements/Image");
local Switcher = require("ui/bricks/elements/switcher/Switcher");
local SwitcherTransition = require("ui/bricks/elements/switcher/SwitcherTransition");

local TestTransition = Class:test("TestTransition", SwitcherTransition);

TestTransition.init = function(self)
	TestTransition.super.init(self, 10, math.ease_linear);
end

TestTransition.compute_desired_size = function(self)
	return 50, 100;
end

TestTransition.draw = function(self, width, height)
	self.drawnAtProgress = self:getProgress();
end

crystal.test.add("Shows first child by default", function()
	local drawnElements = {};
	local draw = function(self)
		drawnElements[self] = true;
	end

	local switcher = Switcher:new();
	local a = switcher:add_child(UIElement:new());
	a.draw_self = draw;
	local b = switcher:add_child(UIElement:new());
	b.draw_self = draw;
	switcher:update_tree(0);
	switcher:draw();
	assert(drawnElements[a]);
	assert(not drawnElements[b]);
end

crystal.test.add("Can snap to different child", function()
	local drawnElements = {};
	local draw = function(self)
		drawnElements[self] = true;
	end

	local switcher = Switcher:new();
	local a = switcher:add_child(UIElement:new());
	a.draw_self = draw;
	local b = switcher:add_child(UIElement:new());
	b.draw_self = draw;
	switcher:jumpToChild(b);
	switcher:update_tree(0);
	switcher:draw();
	assert(not drawnElements[a]);
	assert(drawnElements[b]);
end

crystal.test.add("Supports dynamic or bounding box sizing", function()
	for _, test in pairs({
		{ method = "sizeToActiveChild", expectedSize = { 0, 50, 0, 100 } },
		{ method = "sizeToFitAnyChild", expectedSize = { 0, 100, 0, 100 } },
	}) do
		local switcher = Switcher:new();
		local a = switcher:add_child(Image:new());
		a:setImageSize(50, 100);
		local b = switcher:add_child(Image:new());
		b:setImageSize(100, 50);
		switcher[test.method](switcher);
		switcher:update_tree(0);
		assert(table.equals(test.expectedSize, { switcher:relative_position() }));
	end
end);

crystal.test.add("Can transition to a different child", function()
	local drawnElements = {};
	local draw = function(self)
		drawnElements[self] = true;
	end

	local switcher = Switcher:new();
	local a = switcher:add_child(UIElement:new());
	a.draw_self = draw;
	local b = switcher:add_child(UIElement:new());
	b.draw_self = draw;

	switcher:transitionToChild(b);
	switcher:update_tree(0);
	switcher:draw();
	assert(not drawnElements[a]);
	assert(drawnElements[b]);
end

crystal.test.add("Applies transition sizing and draw function during transition", function()
	local transition = TestTransition:new();
	local switcher = Switcher:new(transition);
	local a = switcher:add_child(Image:new());
	local b = switcher:add_child(Image:new());
	switcher:transitionToChild(b);

	switcher:update_tree(5);
	assert(table.equals({ 0, 50, 0, 100 }, { a:relative_position() }));
	assert(table.equals({ 0, 50, 0, 100 }, { b:relative_position() }));

	switcher:draw();
	assert(transition.drawnAtProgress == 0.5);
end

crystal.test.add("Can interrupt a transition by setting active child", function()
	local transition = TestTransition:new();
	local switcher = Switcher:new(transition);
	local a = switcher:add_child(Image:new());
	local b = switcher:add_child(Image:new());
	switcher:transitionToChild(b);

	switcher:update_tree(5);
	assert(table.equals({ 0, 50, 0, 100 }, { a:relative_position() }));
	assert(table.equals({ 0, 50, 0, 100 }, { b:relative_position() }));

	switcher:jumpToChild(b);
	assert(transition.drawnAtProgress == nil);
end

crystal.test.add("Can interrupt a transition by starting another one", function()
	local transition = TestTransition:new();
	local switcher = Switcher:new(transition);
	local a = switcher:add_child(Image:new());
	local b = switcher:add_child(Image:new());
	switcher:transitionToChild(b);

	switcher:update_tree(5);
	assert(table.equals({ 0, 50, 0, 100 }, { a:relative_position() }));
	assert(table.equals({ 0, 50, 0, 100 }, { b:relative_position() }));

	switcher:transitionToChild(a);
	switcher:update_tree(2);
	switcher:draw();

	assert(transition.drawnAtProgress == 0.2);
end

crystal.test.add("Ignores transition to current child", function()
	local transition = TestTransition:new();
	local switcher = Switcher:new(transition);
	local a = switcher:add_child(Image:new());
	local b = switcher:add_child(Image:new());
	switcher:transitionToChild(b);

	switcher:update_tree(5);
	assert(table.equals({ 0, 50, 0, 100 }, { a:relative_position() }));
	assert(table.equals({ 0, 50, 0, 100 }, { b:relative_position() }));

	switcher:transitionToChild(b);
	switcher:update_tree(2);
	switcher:draw();

	assert(transition.drawnAtProgress == 0.7);
end

return tests;
