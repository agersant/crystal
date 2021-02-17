require("engine/utils/OOP");
local Container = require("engine/ui/bricks/core/Container");
local Padding = require("engine/ui/bricks/core/Padding");
local HorizontalAlignment = require("engine/ui/bricks/core/HorizontalAlignment");
local VerticalAlignment = require("engine/ui/bricks/core/VerticalAlignment");
local BasicJoint = require("engine/ui/bricks/core/BasicJoint");

local SwitcherJoint = Class("SwitcherJoint", BasicJoint);
local Switcher = Class("Switcher", Container);

SwitcherJoint.init = function(self, parent, child)
	SwitcherJoint.super.init(self, parent, child);
	self._horizontalAlignment = HorizontalAlignment.LEFT;
	self._verticalAlignment = VerticalAlignment.TOP;
end

Switcher.init = function(self)
	Switcher.super.init(self, SwitcherJoint);
	self._activeChild = nil;
end

Switcher.setActiveChild = function(self, child)
	assert(not child or child:getParent() == self)
	self._activeChild = child;
end

Switcher.addChild = function(self, child)
	local wasEmpty = #self._children == 0;
	local child = Switcher.super.addChild(self, child);
	assert(child:getParent() == self);
	if wasEmpty then
		self._activeChild = child;
	end
	return child;
end

Switcher.removeChild = function(self, child)
	Switcher.super.removeChild(self, child);
	if self._activeChild == child then
		self._activeChild = nil;
	end
end

Switcher.computeDesiredSize = function(self)
	local width, height = 0, 0;
	if self._activeChild then
		local joint = self._childJoints[self._activeChild];
		local childWidth, childHeight = self._activeChild:getDesiredSize();
		local paddingLeft, paddingRight, paddingTop, paddingBottom = joint:getEachPadding();
		width = childWidth + paddingLeft + paddingRight;
		height = childHeight + paddingTop + paddingBottom;
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
	if self._activeChild then
		self._activeChild:draw();
	end
end

return Switcher;
