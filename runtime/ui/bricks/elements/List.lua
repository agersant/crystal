local BricksUtils = require("ui/bricks/core/BricksUtils");
local Container = require("ui/bricks/core/Container");
local Joint = require("ui/bricks/core/Joint");
local Padding = require("ui/bricks/core/Padding");
local Alias = require("utils/Alias");

local ListJoint = Class("ListJoint", Joint);
local HorizontalListJoint = Class("HorizontalListJoint", ListJoint);
local VerticalListJoint = Class("VerticalListJoint", ListJoint);

local List = Class("List", Container);
List.Horizontal = Class("HorizontalList", List);
List.Vertical = Class("VerticalList", List);

ListJoint.init = function(self, parent, child)
	ListJoint.super.init(self, parent, child);
	self._padding = Padding:new();
	self._grow = 0;
	self._shrink = 0;
	Alias:add(self, self._padding);
end

ListJoint.getAlignment = function(self)
	error("Not implemented");
end

ListJoint.getGrow = function(self)
	return self._grow;
end

ListJoint.setGrow = function(self, amount)
	assert(amount);
	self._grow = amount;
end

ListJoint.getShrink = function(self)
	return self._shrink;
end

ListJoint.setShrink = function(self, amount)
	assert(amount);
	self._shrink = amount;
end

HorizontalListJoint.init = function(self, parent, child)
	HorizontalListJoint.super.init(self, parent, child);
	self._verticalAlignment = "top";
end

HorizontalListJoint.getVerticalAlignment = function(self)
	return self._verticalAlignment;
end

HorizontalListJoint.setVerticalAlignment = function(self, alignment)
	assert(BricksUtils.isVerticalAlignment(alignment));
	self._verticalAlignment = alignment;
end

VerticalListJoint.init = function(self, parent, child)
	VerticalListJoint.super.init(self, parent, child);
	self._horizontalAlignment = "left";
end

VerticalListJoint.getHorizontalAlignment = function(self)
	return self._horizontalAlignment;
end

VerticalListJoint.setHorizontalAlignment = function(self, alignment)
	assert(BricksUtils.isHorizontalAlignment(alignment));
	self._horizontalAlignment = alignment;
end

List.Horizontal.init = function(self)
	List.Horizontal.super.init(self, "horizontal");
end

List.Vertical.init = function(self)
	List.Vertical.super.init(self, "vertical");
end

List.init = function(self, axis)
	assert(axis == "horizontal" or axis == "vertical");
	self._axis = axis;
	List.super.init(self, axis == "horizontal" and HorizontalListJoint or VerticalListJoint);
end

List.computeDesiredSize = function(self)
	local width, height = 0, 0;
	for child, joint in pairs(self._childJoints) do
		local childWidth, childHeight = child:getDesiredSize();
		local paddingLeft, paddingRight, paddingTop, paddingBottom = joint:getEachPadding();
		if self._axis == "horizontal" then
			width = width + childWidth + paddingLeft + paddingRight;
			height = math.max(height, childHeight + paddingTop + paddingBottom);
		else
			height = height + childHeight + paddingTop + paddingBottom;
			width = math.max(width, childWidth + paddingLeft + paddingRight);
		end
	end
	return math.max(width, 0), math.max(height, 0);
end

List.arrangeChildren = function(self)
	local width, height = self:getSize();
	local desiredWidth, desiredHeight = self:getDesiredSize();

	local totalGrow = 0;
	local totalShrink = 0;
	for _, child in ipairs(self._children) do
		local joint = self._childJoints[child];
		totalGrow = totalGrow + joint:getGrow();
		totalShrink = totalShrink + joint:getShrink();
	end

	local x = 0;
	local y = 0;
	for _, child in ipairs(self._children) do
		local joint = self._childJoints[child];
		local childDesiredWidth, childDesiredHeight = child:getDesiredSize();
		local paddingLeft, paddingRight, paddingTop, paddingBottom = joint:getEachPadding();
		local grow = joint:getGrow();
		local shrink = joint:getShrink();

		local childWidth, childHeight;

		if self._axis == "horizontal" then
			x = x + paddingLeft;
			childWidth = childDesiredWidth;
			if width > desiredWidth and grow > 0 then
				childWidth = childDesiredWidth + (grow / totalGrow) * (width - desiredWidth);
			elseif width < desiredWidth and shrink > 0 then
				childWidth = childDesiredWidth - (shrink / totalShrink) * (desiredWidth - width);
			end

			local verticalAlignment = joint:getVerticalAlignment();
			assert(BricksUtils.isVerticalAlignment(verticalAlignment));
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
		else
			y = y + paddingTop;
			childHeight = childDesiredHeight;
			if height > desiredHeight and grow > 0 then
				childHeight = childDesiredHeight + (grow / totalGrow) * (height - desiredHeight);
			elseif height < desiredHeight and shrink > 0 then
				childHeight = childDesiredHeight - (shrink / totalShrink) * (desiredHeight - height);
			end

			local horizontalAlignment = joint:getHorizontalAlignment();
			assert(BricksUtils.isHorizontalAlignment(horizontalAlignment));
			if horizontalAlignment == "stretch" then
				childWidth = width - paddingLeft - paddingRight;
				x = paddingLeft;
			elseif horizontalAlignment == "left" then
				childWidth = childDesiredWidth;
				x = paddingLeft;
			elseif horizontalAlignment == "center" then
				childWidth = childDesiredWidth;
				x = (width - childWidth) / 2 + paddingLeft - paddingRight;
			elseif horizontalAlignment == "right" then
				childWidth = childDesiredWidth;
				x = width - childWidth - paddingRight;
			end
		end

		child:setLocalPosition(x, x + childWidth, y, y + childHeight);

		if self._axis == "horizontal" then
			x = x + childWidth + paddingRight;
		else
			y = y + childHeight + paddingBottom;
		end
	end
end

return List;
