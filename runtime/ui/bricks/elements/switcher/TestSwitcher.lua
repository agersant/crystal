local Element = require("ui/bricks/core/Element");
local Image = require("ui/bricks/elements/Image");
local Switcher = require("ui/bricks/elements/switcher/Switcher");
local SwitcherTransition = require("ui/bricks/elements/switcher/SwitcherTransition");

local TestTransition = Class:test("TestTransition", SwitcherTransition);

TestTransition.init = function(self)
	TestTransition.super.init(self, 10, math.ease_linear);
end

TestTransition.computeDesiredSize = function(self)
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
	local a = switcher:addChild(Element:new());
	a.drawSelf = draw;
	local b = switcher:addChild(Element:new());
	b.drawSelf = draw;
	switcher:updateTree(0);
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
	local a = switcher:addChild(Element:new());
	a.drawSelf = draw;
	local b = switcher:addChild(Element:new());
	b.drawSelf = draw;
	switcher:jumpToChild(b);
	switcher:updateTree(0);
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
		local a = switcher:addChild(Image:new());
		a:setImageSize(50, 100);
		local b = switcher:addChild(Image:new());
		b:setImageSize(100, 50);
		switcher[test.method](switcher);
		switcher:updateTree(0);
		assert(table.equals(test.expectedSize, { switcher:getLocalPosition() }));
	end
end);

crystal.test.add("Can transition to a different child", function()
	local drawnElements = {};
	local draw = function(self)
		drawnElements[self] = true;
	end

	local switcher = Switcher:new();
	local a = switcher:addChild(Element:new());
	a.drawSelf = draw;
	local b = switcher:addChild(Element:new());
	b.drawSelf = draw;

	switcher:transitionToChild(b);
	switcher:updateTree(0);
	switcher:draw();
	assert(not drawnElements[a]);
	assert(drawnElements[b]);
end

crystal.test.add("Applies transition sizing and draw function during transition", function()
	local transition = TestTransition:new();
	local switcher = Switcher:new(transition);
	local a = switcher:addChild(Image:new());
	local b = switcher:addChild(Image:new());
	switcher:transitionToChild(b);

	switcher:updateTree(5);
	assert(table.equals({ 0, 50, 0, 100 }, { a:getLocalPosition() }));
	assert(table.equals({ 0, 50, 0, 100 }, { b:getLocalPosition() }));

	switcher:draw();
	assert(transition.drawnAtProgress == 0.5);
end

crystal.test.add("Can interrupt a transition by setting active child", function()
	local transition = TestTransition:new();
	local switcher = Switcher:new(transition);
	local a = switcher:addChild(Image:new());
	local b = switcher:addChild(Image:new());
	switcher:transitionToChild(b);

	switcher:updateTree(5);
	assert(table.equals({ 0, 50, 0, 100 }, { a:getLocalPosition() }));
	assert(table.equals({ 0, 50, 0, 100 }, { b:getLocalPosition() }));

	switcher:jumpToChild(b);
	assert(transition.drawnAtProgress == nil);
end

crystal.test.add("Can interrupt a transition by starting another one", function()
	local transition = TestTransition:new();
	local switcher = Switcher:new(transition);
	local a = switcher:addChild(Image:new());
	local b = switcher:addChild(Image:new());
	switcher:transitionToChild(b);

	switcher:updateTree(5);
	assert(table.equals({ 0, 50, 0, 100 }, { a:getLocalPosition() }));
	assert(table.equals({ 0, 50, 0, 100 }, { b:getLocalPosition() }));

	switcher:transitionToChild(a);
	switcher:updateTree(2);
	switcher:draw();

	assert(transition.drawnAtProgress == 0.2);
end

crystal.test.add("Ignores transition to current child", function()
	local transition = TestTransition:new();
	local switcher = Switcher:new(transition);
	local a = switcher:addChild(Image:new());
	local b = switcher:addChild(Image:new());
	switcher:transitionToChild(b);

	switcher:updateTree(5);
	assert(table.equals({ 0, 50, 0, 100 }, { a:getLocalPosition() }));
	assert(table.equals({ 0, 50, 0, 100 }, { b:getLocalPosition() }));

	switcher:transitionToChild(b);
	switcher:updateTree(2);
	switcher:draw();

	assert(transition.drawnAtProgress == 0.7);
end

return tests;
