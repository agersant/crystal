require("engine/utils/OOP");
local VerticalAlignment = require("engine/ui/bricks/core/VerticalAlignment");
local Container = require("engine/ui/bricks/core/Container");
local Joint = require("engine/ui/bricks/core/Joint");

local HorizontalBoxJoint = Class("HorizontalBoxJoint", Joint);
local HorizontalBox = Class("HorizontalBox", Container);

HorizontalBoxJoint.init = function(self, parent, child)
	HorizontalBoxJoint.super.init(self, parent, child);
	self._paddingLeft = 0;
	self._paddingRight = 0;
	self._paddingTop = 0;
	self._paddingBottom = 0;
	self._verticalAlignment = VerticalAlignment.TOP;
	self._grow = 0;
	self._shrink = 0;
end

HorizontalBoxJoint.getPadding = function(self)
	return self._paddingLeft, self._paddingRight, self._paddingTop, self._paddingBottom;
end

HorizontalBoxJoint.getVerticalAlignment = function(self)
	return self._alignment;
end

HorizontalBoxJoint.getGrow = function(self)
	return self._grow;
end

HorizontalBoxJoint.getShrink = function(self)
	return self._shrink;
end

HorizontalBox.init = function(self)
	HorizontalBox.super.init(self, HorizontalBoxJoint);
end

HorizontalBox.getDesiredSize = function(self)
	local width, height = 0, 0;
	for child, joint in pairs(self._joints) do
		local childWidth, childHeight = child:getDesiredSize();
		local paddingLeft, paddingRight, paddingTop, paddingBottom = joint:getPadding();
		width = width + childWidth + paddingLeft + paddingRight;
		height = math.max(height, childHeight + paddingTop + paddingBottom);
	end
	return math.max(width, 0), math.max(height, 0);
end

HorizontalBox.arrangeChildren = function(self)
	local width, height = self:getSize();
	local desiredWidth, _desiredHeight = self:getSize();

	local totalGrow = 0;
	local totalShrink = 0;
	for _, child in ipairs(self._children) do
		local joint = self._joints[child];
		totalGrow = totalGrow + joint:getGrow();
		totalShrink = totalShrink + joint:getShrink();
	end

	local x = 0;
	for _, child in ipairs(self._children) do
		local joint = self._joints[child];
		local childDesiredWidth, childDesiredHeight = child:getDesiredSize();
		local paddingLeft, paddingRight, paddingTop, paddingBottom = joint:getPadding();
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
		if verticalAlignment == VerticalAlignment.STRETCH then
			childHeight = height - paddingTop - paddingBottom;
			y = height + paddingTop;
		elseif verticalAlignment == VerticalAlignment.TOP then
			childHeight = childDesiredHeight;
			y = height + paddingTop;
		elseif verticalAlignment == VerticalAlignment.CENTER then
			childHeight = childDesiredHeight;
			y = (height - childHeight) / 2 + paddingTop - paddingBottom;
		elseif verticalAlignment == VerticalAlignment.BOTTOM then
			childHeight = childDesiredHeight;
			y = height - childHeight - paddingBottom;
		end

		child:setLocalPosition(x, x + childWidth, y, y + childHeight);
		x = x + paddingRight;
	end
end

return HorizontalBox;
