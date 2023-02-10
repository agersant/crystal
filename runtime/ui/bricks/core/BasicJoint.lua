local Joint = require("ui/bricks/core/Joint");
local Padding = require("ui/bricks/core/Padding");
local BricksUtils = require("ui/bricks/core/BricksUtils");
local Alias = require("utils/Alias");

local BasicJoint = Class("BasicJoint", Joint);

BasicJoint.init = function(self, parent, child)
	BasicJoint.super.init(self, parent, child);
	self._padding = Padding:new();
	self._horizontalAlignment = "stretch";
	self._verticalAlignment = "stretch";
	Alias:add(self, self._padding);
end

BasicJoint.getAlignment = function(self)
	return self._horizontalAlignment, self._verticalAlignment;
end

BasicJoint.getHorizontalAlignment = function(self)
	return self._horizontalAlignment;
end

BasicJoint.getVerticalAlignment = function(self)
	return self._verticalAlignment;
end

BasicJoint.setAlignment = function(self, horizontal, vertical)
	self:setHorizontalAlignment(horizontal);
	self:setVerticalAlignment(vertical);
end

BasicJoint.setHorizontalAlignment = function(self, alignment)
	assert(BricksUtils.isHorizontalAlignment(alignment));
	self._horizontalAlignment = alignment;
end

BasicJoint.setVerticalAlignment = function(self, alignment)
	assert(BricksUtils.isVerticalAlignment(alignment));
	self._verticalAlignment = alignment;
end

BasicJoint.computeDesiredSize = function(self, desiredWidth, desiredHeight)
	local paddingLeft, paddingRight, paddingTop, paddingBottom = self:getEachPadding();
	local width = desiredWidth + paddingLeft + paddingRight;
	local height = desiredHeight + paddingTop + paddingBottom;
	return math.max(0, width), math.max(0, height);
end

BasicJoint.computeLocalPosition = function(self, desiredWidth, desiredHeight, parentWidth, parentHeight)

	local paddingLeft, paddingRight, paddingTop, paddingBottom = self:getEachPadding();
	local horizontalAlignment = self:getHorizontalAlignment();
	local verticalAlignment = self:getVerticalAlignment();

	local childWidth = desiredWidth;
	if horizontalAlignment == "stretch" then
		childWidth = parentWidth - paddingLeft - paddingRight;
	end
	childWidth = math.max(0, childWidth);

	local childHeight = desiredHeight;
	if verticalAlignment == "stretch" then
		childHeight = parentHeight - paddingTop - paddingBottom;
	end
	childHeight = math.max(0, childHeight);

	local x;
	if horizontalAlignment == "left" then
		x = paddingLeft;
	elseif horizontalAlignment == "center" then
		x = (parentWidth - childWidth) / 2 + paddingLeft - paddingRight;
	elseif horizontalAlignment == "right" then
		x = parentWidth - childWidth - paddingRight;
	elseif horizontalAlignment == "stretch" then
		x = paddingLeft;
	end

	local y;
	if verticalAlignment == "top" then
		y = paddingTop;
	elseif verticalAlignment == "center" then
		y = (parentHeight - childHeight) / 2 + paddingTop - paddingBottom;
	elseif verticalAlignment == "bottom" then
		y = parentHeight - childHeight - paddingBottom;
	elseif verticalAlignment == "stretch" then
		y = paddingTop;
	end

	return x, x + childWidth, y, y + childHeight;
end

return BasicJoint;
