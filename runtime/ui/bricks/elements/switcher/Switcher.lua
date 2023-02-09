local BasicJoint = require("ui/bricks/core/BasicJoint");
local Container = require("ui/bricks/core/Container");
local Padding = require("ui/bricks/core/Padding");
local MathUtils = require("utils/MathUtils");
local SwitcherTransition = require("ui/bricks/elements/switcher/SwitcherTransition");

local SwitcherJoint = Class("SwitcherJoint", BasicJoint);
local Switcher = Class("Switcher", Container);

SwitcherJoint.init = function(self, parent, child)
	SwitcherJoint.super.init(self, parent, child);
	self._horizontalAlignment = "stretch";
	self._verticalAlignment = "stretch";
end

Switcher.init = function(self, transition)
	Switcher.super.init(self, SwitcherJoint);
	self._activeChild = nil;
	self._transition = transition or SwitcherTransition:new();
	self._useDynamicSize = true;
end

Switcher.sizeToActiveChild = function(self)
	self._useDynamicSize = true;
end

Switcher.sizeToFitAnyChild = function(self)
	self._useDynamicSize = false;
end

Switcher.update = function(self, dt)
	Switcher.super.update(self, dt);
	if not self._transition:isOver() then
		self._transition:update(dt);
	end
end

Switcher.jumpToChild = function(self, child)
	assert(not child or child:getParent() == self);
	self._activeChild = child;
	self._transition:play(nil, child);
	self._transition:skipToEnd();
end

Switcher.transitionToChild = function(self, child)
	assert(not child or child:getParent() == self);
	if self._activeChild == child then
		return;
	end
	local previousChild = self._activeChild;
	self._activeChild = child;
	return self._transition:play(previousChild, child);
end

Switcher.addChild = function(self, child)
	local wasEmpty = #self._children == 0;
	local child = Switcher.super.addChild(self, child);
	assert(child:getParent() == self);
	if wasEmpty then
		self:jumpToChild(child);
	end
	return child;
end

Switcher.removeChild = function(self, child)
	Switcher.super.removeChild(self, child);
	self._transition:handleChildRemoved(child);
end

Switcher.computeDesiredSize = function(self)
	local width, height;
	if self._useDynamicSize then
		if self._transition:isOver() then
			-- Size to active child
			local joint = self._childJoints[self._activeChild];
			local childWidth, childHeight = self._activeChild:getDesiredSize();
			width, height = joint:computeDesiredSize(childWidth, childHeight);
		else
			-- Active transition decides size
			width, height = self._transition:computeDesiredSize();
		end
	else
		-- Size to bounding box of all children
		width, height = 0, 0;
		for child, joint in pairs(self._childJoints) do
			local childWidth, childHeight = child:getDesiredSize();
			childWidth, childHeight = joint:computeDesiredSize(childWidth, childHeight);
			width = math.max(width, childWidth);
			height = math.max(height, childHeight);
		end
	end
	return math.max(width, 0), math.max(height, 0);
end

Switcher.arrangeChildren = function(self)
	local width, height = self:getSize();
	for _, child in ipairs(self._children) do
		local joint = self._childJoints[child];
		local childWidth, childHeight = child:getDesiredSize();
		local left, right, top, bottom = joint:computeLocalPosition(childWidth, childHeight, width, height);
		child:setLocalPosition(left, right, top, bottom);
	end
end

Switcher.drawSelf = function(self)
	if self._transition:isOver() then
		if self._activeChild then
			self._activeChild:draw();
		end
	else
		local width, height = self:getSize();
		self._transition:draw(width, height, self._previousChild, self._activeChild);
	end
end

--#region Tests

local Element = require("ui/bricks/core/Element");
local Image = require("ui/bricks/elements/Image");
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

crystal.test.add("Shows first child by default", { gfx = "mock" }, function()
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

crystal.test.add("Can snap to different child", { gfx = "mock" }, function()
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
		assert(TableUtils.equals(test.expectedSize, { switcher:getLocalPosition() }));
	end
end);

crystal.test.add("Can transition to a different child", { gfx = "mock" }, function()
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

crystal.test.add("Applies transition sizing and draw function during transition", { gfx = "mock" }, function()
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

crystal.test.add("Can interrupt a transition by setting active child", { gfx = "mock" }, function()
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

crystal.test.add("Can interrupt a transition by starting another one", { gfx = "mock" }, function()
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

crystal.test.add("Ignores transition to current child", { gfx = "mock" }, function()
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

--#endregion

return Switcher;
