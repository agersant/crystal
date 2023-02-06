local Element = require("ui/bricks/core/Element");
local Image = require("ui/bricks/elements/Image");
local Switcher = require("ui/bricks/elements/switcher/Switcher");
local SwitcherTransition = require("ui/bricks/elements/switcher/SwitcherTransition");
local TableUtils = require("utils/TableUtils");

local TestTransition = Class:test("TestTransition", SwitcherTransition);

TestTransition.init = function(self)
	TestTransition.super.init(self, 10, "linear");
end

TestTransition.computeDesiredSize = function(self)
	return 50, 100;
end

TestTransition.draw = function(self, width, height)
	self.drawnAtProgress = self:getProgress();
end

local tests = {};

tests[#tests + 1] = { name = "Shows first child by default", gfx = "mock" };
tests[#tests].body = function()
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

tests[#tests + 1] = { name = "Can snap to different child", gfx = "mock" };
tests[#tests].body = function()
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

tests[#tests + 1] = { name = "Supports dynamic or bounding box sizing" };
tests[#tests].body = function()
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
		assert(TableUtils.equals(test.expectedSize, { switcher:getLocalPosition() }));
	end
end

tests[#tests + 1] = { name = "Can transition to a different child", gfx = "mock" };
tests[#tests].body = function()
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

tests[#tests + 1] = { name = "Applies transition sizing and draw function during transition", gfx = "mock" };
tests[#tests].body = function()
	local transition = TestTransition:new();
	local switcher = Switcher:new(transition);
	local a = switcher:addChild(Image:new());
	local b = switcher:addChild(Image:new());
	switcher:transitionToChild(b);

	switcher:updateTree(5);
	assert(TableUtils.equals({ 0, 50, 0, 100 }, { a:getLocalPosition() }));
	assert(TableUtils.equals({ 0, 50, 0, 100 }, { b:getLocalPosition() }));

	switcher:draw();
	assert(transition.drawnAtProgress == 0.5);
end

tests[#tests + 1] = { name = "Can interrupt a transition by setting active child", gfx = "mock" };
tests[#tests].body = function()
	local transition = TestTransition:new();
	local switcher = Switcher:new(transition);
	local a = switcher:addChild(Image:new());
	local b = switcher:addChild(Image:new());
	switcher:transitionToChild(b);

	switcher:updateTree(5);
	assert(TableUtils.equals({ 0, 50, 0, 100 }, { a:getLocalPosition() }));
	assert(TableUtils.equals({ 0, 50, 0, 100 }, { b:getLocalPosition() }));

	switcher:jumpToChild(b);
	assert(transition.drawnAtProgress == nil);
end

tests[#tests + 1] = { name = "Can interrupt a transition by starting another one", gfx = "mock" };
tests[#tests].body = function()
	local transition = TestTransition:new();
	local switcher = Switcher:new(transition);
	local a = switcher:addChild(Image:new());
	local b = switcher:addChild(Image:new());
	switcher:transitionToChild(b);

	switcher:updateTree(5);
	assert(TableUtils.equals({ 0, 50, 0, 100 }, { a:getLocalPosition() }));
	assert(TableUtils.equals({ 0, 50, 0, 100 }, { b:getLocalPosition() }));

	switcher:transitionToChild(a);
	switcher:updateTree(2);
	switcher:draw();

	assert(transition.drawnAtProgress == 0.2);
end

tests[#tests + 1] = { name = "Ignores transition to current child", gfx = "mock" };
tests[#tests].body = function()
	local transition = TestTransition:new();
	local switcher = Switcher:new(transition);
	local a = switcher:addChild(Image:new());
	local b = switcher:addChild(Image:new());
	switcher:transitionToChild(b);

	switcher:updateTree(5);
	assert(TableUtils.equals({ 0, 50, 0, 100 }, { a:getLocalPosition() }));
	assert(TableUtils.equals({ 0, 50, 0, 100 }, { b:getLocalPosition() }));

	switcher:transitionToChild(b);
	switcher:updateTree(2);
	switcher:draw();

	assert(transition.drawnAtProgress == 0.7);
end

return tests;
