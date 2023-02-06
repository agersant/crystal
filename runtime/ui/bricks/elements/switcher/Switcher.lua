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

return Switcher;
