local BasicJoint = require("ui/bricks/core/BasicJoint");
local Container = require("modules/ui/container");
local Padding = require("ui/bricks/core/Padding");
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
	assert(not child or child:parent() == self);
	self._activeChild = child;
	self._transition:play(nil, child);
	self._transition:skipToEnd();
end

Switcher.transitionToChild = function(self, child)
	assert(not child or child:parent() == self);
	if self._activeChild == child then
		return;
	end
	local previousChild = self._activeChild;
	self._activeChild = child;
	return self._transition:play(previousChild, child);
end

Switcher.add_child = function(self, child)
	local wasEmpty = #self._children == 0;
	local child = Switcher.super.add_child(self, child);
	assert(child:parent() == self);
	if wasEmpty then
		self:jumpToChild(child);
	end
	return child;
end

Switcher.remove_child = function(self, child)
	Switcher.super.remove_child(self, child);
	self._transition:handleChildRemoved(child);
end

Switcher.compute_desired_size = function(self)
	local width, height;
	if self._useDynamicSize then
		if self._transition:isOver() then
			-- Size to active child
			local joint = self.child_joints[self._activeChild];
			local childWidth, childHeight = self._activeChild:desired_size();
			width, height = joint:compute_desired_size(childWidth, childHeight);
		else
			-- Active transition decides size
			width, height = self._transition:compute_desired_size();
		end
	else
		-- Size to bounding box of all children
		width, height = 0, 0;
		for child, joint in pairs(self.child_joints) do
			local childWidth, childHeight = child:desired_size();
			childWidth, childHeight = joint:compute_desired_size(childWidth, childHeight);
			width = math.max(width, childWidth);
			height = math.max(height, childHeight);
		end
	end
	return math.max(width, 0), math.max(height, 0);
end

Switcher.arrange_children = function(self)
	local width, height = self:size();
	for _, child in ipairs(self._children) do
		local joint = self.child_joints[child];
		local childWidth, childHeight = child:desired_size();
		local left, right, top, bottom = joint:computeLocalPosition(childWidth, childHeight, width, height);
		child:set_relative_position(left, right, top, bottom);
	end
end

Switcher.draw_self = function(self)
	if self._transition:isOver() then
		if self._activeChild then
			self._activeChild:draw();
		end
	else
		local width, height = self:size();
		self._transition:draw(width, height, self._previousChild, self._activeChild);
	end
end

--#region Tests

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
	local a = switcher:add_child(crystal.UIElement:new());
	a.draw_self = draw;
	local b = switcher:add_child(crystal.UIElement:new());
	b.draw_self = draw;
	switcher:update_tree(0);
	switcher:draw();
	assert(drawnElements[a]);
	assert(not drawnElements[b]);
end);

crystal.test.add("Can snap to different child", function()
	local drawnElements = {};
	local draw = function(self)
		drawnElements[self] = true;
	end

	local switcher = Switcher:new();
	local a = switcher:add_child(crystal.UIElement:new());
	a.draw_self = draw;
	local b = switcher:add_child(crystal.UIElement:new());
	b.draw_self = draw;
	switcher:jumpToChild(b);
	switcher:update_tree(0);
	switcher:draw();
	assert(not drawnElements[a]);
	assert(drawnElements[b]);
end);

crystal.test.add("Supports dynamic or bounding box sizing", function()
	for _, test in pairs({
		{ method = "sizeToActiveChild", expectedSize = { 0, 50, 0, 100 } },
		{ method = "sizeToFitAnyChild", expectedSize = { 0, 100, 0, 100 } },
	}) do
		local switcher = Switcher:new();
		local a = switcher:add_child(crystal.Image:new());
		a:set_image_size(50, 100);
		local b = switcher:add_child(crystal.Image:new());
		b:set_image_size(100, 50);
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
	local a = switcher:add_child(crystal.UIElement:new());
	a.draw_self = draw;
	local b = switcher:add_child(crystal.UIElement:new());
	b.draw_self = draw;

	switcher:transitionToChild(b);
	switcher:update_tree(0);
	switcher:draw();
	assert(not drawnElements[a]);
	assert(drawnElements[b]);
end);

crystal.test.add("Applies transition sizing and draw function during transition", function()
	local transition = TestTransition:new();
	local switcher = Switcher:new(transition);
	local a = switcher:add_child(crystal.Image:new());
	local b = switcher:add_child(crystal.Image:new());
	switcher:transitionToChild(b);

	switcher:update_tree(5);
	assert(table.equals({ a:relative_position() }, { 0, 50, 0, 100 }));
	assert(table.equals({ b:relative_position() }, { 0, 50, 0, 100 }));

	switcher:draw();
	assert(transition.drawnAtProgress == 0.5);
end);

crystal.test.add("Can interrupt a transition by setting active child", function()
	local transition = TestTransition:new();
	local switcher = Switcher:new(transition);
	local a = switcher:add_child(crystal.Image:new());
	local b = switcher:add_child(crystal.Image:new());
	switcher:transitionToChild(b);

	switcher:update_tree(5);
	assert(table.equals({ a:relative_position() }, { 0, 50, 0, 100 }));
	assert(table.equals({ b:relative_position() }, { 0, 50, 0, 100 }));

	switcher:jumpToChild(b);
	assert(transition.drawnAtProgress == nil);
end);

crystal.test.add("Can interrupt a transition by starting another one", function()
	local transition = TestTransition:new();
	local switcher = Switcher:new(transition);
	local a = switcher:add_child(crystal.Image:new());
	local b = switcher:add_child(crystal.Image:new());
	switcher:transitionToChild(b);

	switcher:update_tree(5);
	assert(table.equals({ a:relative_position() }, { 0, 50, 0, 100 }));
	assert(table.equals({ b:relative_position() }, { 0, 50, 0, 100 }));

	switcher:transitionToChild(a);
	switcher:update_tree(2);
	switcher:draw();

	assert(transition.drawnAtProgress == 0.2);
end);

crystal.test.add("Ignores transition to current child", function()
	local transition = TestTransition:new();
	local switcher = Switcher:new(transition);
	local a = switcher:add_child(crystal.Image:new());
	local b = switcher:add_child(crystal.Image:new());
	switcher:transitionToChild(b);

	switcher:update_tree(5);
	assert(table.equals({ a:relative_position() }, { 0, 50, 0, 100 }));
	assert(table.equals({ b:relative_position() }, { 0, 50, 0, 100 }));

	switcher:transitionToChild(b);
	switcher:update_tree(2);
	switcher:draw();

	assert(transition.drawnAtProgress == 0.7);
end);

--#endregion

return Switcher;
