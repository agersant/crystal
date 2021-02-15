require("engine/utils/OOP");
local Container = require("engine/ui/bricks/core/Container");
local Joint = require("engine/ui/bricks/core/Joint");
local Padding = require("engine/ui/bricks/core/Padding");
local HorizontalAlignment = require("engine/ui/bricks/core/HorizontalAlignment");
local Alias = require("engine/utils/Alias");

local VerticalBoxJoint = Class("VerticalBoxJoint", Joint);
local VerticalBox = Class("VerticalBox", Container);

VerticalBoxJoint.init = function(self, parent, child)
	VerticalBoxJoint.super.init(self, parent, child);
	self._padding = Padding:new();
	self._horizontalAlignment = HorizontalAlignment.LEFT;
	self._grow = 0;
	self._shrink = 0;
	Alias:add(self, self._padding);
end

VerticalBoxJoint.getHorizontalAlignment = function(self)
	return self._horizontalAlignment;
end

VerticalBoxJoint.getGrow = function(self)
	return self._grow;
end

VerticalBoxJoint.getShrink = function(self)
	return self._shrink;
end

VerticalBoxJoint.setHorizontalAlignment = function(self, alignment)
	assert(alignment);
	assert(alignment >= HorizontalAlignment.LEFT);
	assert(alignment <= HorizontalAlignment.STRETCH);
	self._horizontalAlignment = alignment;
end

VerticalBoxJoint.setGrow = function(self, amount)
	assert(amount);
	self._grow = amount;
end

VerticalBoxJoint.setShrink = function(self, amount)
	assert(amount);
	self._shrink = amount;
end

VerticalBox.init = function(self)
	VerticalBox.super.init(self, VerticalBoxJoint);
end

VerticalBox.getDesiredSize = function(self)
	local width, height = 0, 0;
	for child, joint in pairs(self._childJoints) do
		local childWidth, childHeight = child:getDesiredSize();
		local paddingLeft, paddingRight, paddingTop, paddingBottom = joint:getEachPadding();
		height = height + childHeight + paddingTop + paddingBottom;
		width = math.max(width, childWidth + paddingLeft + paddingRight);
	end
	return math.max(width, 0), math.max(height, 0);
end

VerticalBox.arrangeChildren = function(self)
	local width, height = self:getSize();
	local _desiredWidth, desiredHeight = self:getDesiredSize();

	local totalGrow = 0;
	local totalShrink = 0;
	for _, child in ipairs(self._children) do
		local joint = self._childJoints[child];
		totalGrow = totalGrow + joint:getGrow();
		totalShrink = totalShrink + joint:getShrink();
	end

	local y = 0;
	for _, child in ipairs(self._children) do
		local joint = self._childJoints[child];
		local childDesiredWidth, childDesiredHeight = child:getDesiredSize();
		local paddingLeft, paddingRight, paddingTop, paddingBottom = joint:getEachPadding();
		local grow = joint:getGrow();
		local shrink = joint:getShrink();
		local horizontalAlignment = joint:getHorizontalAlignment();

		y = y + paddingTop;
		local childHeight = childDesiredHeight;
		if height > desiredHeight and grow > 0 then
			childHeight = childDesiredHeight + (grow / totalGrow) * (height - desiredHeight);
		elseif height < desiredHeight and shrink > 0 then
			childHeight = childDesiredHeight - (shrink / totalShrink) * (desiredHeight - height);
		end

		local childWidth, x;
		if horizontalAlignment == HorizontalAlignment.STRETCH then
			childWidth = width - paddingLeft - paddingRight;
			x = paddingLeft;
		elseif horizontalAlignment == HorizontalAlignment.LEFT then
			childWidth = childDesiredWidth;
			x = paddingLeft;
		elseif horizontalAlignment == HorizontalAlignment.CENTER then
			childWidth = childDesiredWidth;
			x = (width - childWidth) / 2 + paddingLeft - paddingRight;
		elseif horizontalAlignment == HorizontalAlignment.RIGHT then
			childWidth = childDesiredWidth;
			x = width - childWidth - paddingRight;
		end

		child:setLocalPosition(x, x + childWidth, y, y + childHeight);
		y = y + childHeight + paddingBottom;
	end
end

return VerticalBox;
