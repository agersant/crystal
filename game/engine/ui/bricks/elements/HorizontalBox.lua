require("engine/utils/OOP");
local BricksUtils = require("engine/ui/bricks/core/BricksUtils");
local Container = require("engine/ui/bricks/core/Container");
local Joint = require("engine/ui/bricks/core/Joint");
local Padding = require("engine/ui/bricks/core/Padding");
local Alias = require("engine/utils/Alias");

local HorizontalBoxJoint = Class("HorizontalBoxJoint", Joint);
local HorizontalBox = Class("HorizontalBox", Container);

HorizontalBoxJoint.init = function(self, parent, child)
	HorizontalBoxJoint.super.init(self, parent, child);
	self._padding = Padding:new();
	self._verticalAlignment = "top";
	self._grow = 0;
	self._shrink = 0;
	Alias:add(self, self._padding);
end

HorizontalBoxJoint.getVerticalAlignment = function(self)
	return self._verticalAlignment;
end

HorizontalBoxJoint.getGrow = function(self)
	return self._grow;
end

HorizontalBoxJoint.getShrink = function(self)
	return self._shrink;
end

HorizontalBoxJoint.setVerticalAlignment = function(self, alignment)
	assert(BricksUtils.isVerticalAlignment(alignment));
	self._verticalAlignment = alignment;
end

HorizontalBoxJoint.setGrow = function(self, amount)
	assert(amount);
	self._grow = amount;
end

HorizontalBoxJoint.setShrink = function(self, amount)
	assert(amount);
	self._shrink = amount;
end

HorizontalBox.init = function(self)
	HorizontalBox.super.init(self, HorizontalBoxJoint);
end

HorizontalBox.computeDesiredSize = function(self)
	local width, height = 0, 0;
	for child, joint in pairs(self._childJoints) do
		local childWidth, childHeight = child:getDesiredSize();
		local paddingLeft, paddingRight, paddingTop, paddingBottom = joint:getEachPadding();
		width = width + childWidth + paddingLeft + paddingRight;
		height = math.max(height, childHeight + paddingTop + paddingBottom);
	end
	return math.max(width, 0), math.max(height, 0);
end

HorizontalBox.arrangeChildren = function(self)
	local width, height = self:getSize();
	local desiredWidth, _desiredHeight = self:getDesiredSize();

	local totalGrow = 0;
	local totalShrink = 0;
	for _, child in ipairs(self._children) do
		local joint = self._childJoints[child];
		totalGrow = totalGrow + joint:getGrow();
		totalShrink = totalShrink + joint:getShrink();
	end

	local x = 0;
	for _, child in ipairs(self._children) do
		local joint = self._childJoints[child];
		local childDesiredWidth, childDesiredHeight = child:getDesiredSize();
		local paddingLeft, paddingRight, paddingTop, paddingBottom = joint:getEachPadding();
		local grow = joint:getGrow();
		local shrink = joint:getShrink();
		local verticalAlignment = joint:getVerticalAlignment();

		x = x + paddingLeft;
		local childWidth = childDesiredWidth;
		if width > desiredWidth and grow > 0 then
			childWidth = childDesiredWidth + (grow / totalGrow) * (width - desiredWidth);
		elseif width < desiredWidth and shrink > 0 then
			childWidth = childDesiredWidth - (shrink / totalShrink) * (desiredWidth - width);
		end

		local childHeight, y;
		if verticalAlignment == "stretch" then
			childHeight = height - paddingTop - paddingBottom;
			y = paddingTop;
		elseif verticalAlignment == "top" then
			childHeight = childDesiredHeight;
			y = paddingTop;
		elseif verticalAlignment == "center" then
			childHeight = childDesiredHeight;
			y = (height - childHeight) / 2 + paddingTop - paddingBottom;
		elseif verticalAlignment == "bottom" then
			childHeight = childDesiredHeight;
			y = height - childHeight - paddingBottom;
		end

		child:setLocalPosition(x, x + childWidth, y, y + childHeight);
		x = x + childWidth + paddingRight;
	end
end

return HorizontalBox;
