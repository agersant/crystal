require("engine/utils/OOP");
local HorizontalAlignment = require("engine/ui/bricks/core/HorizontalAlignment");
local Joint = require("engine/ui/bricks/core/Joint");
local Padding = require("engine/ui/bricks/core/Padding");
local VerticalAlignment = require("engine/ui/bricks/core/VerticalAlignment");
local Alias = require("engine/utils/Alias");

-- TODO move to bricks/core
local BasicJoint = Class("BasicJoint", Joint);

BasicJoint.init = function(self, parent, child)
	BasicJoint.super.init(self, parent, child);
	self._padding = Padding:new();
	self._horizontalAlignment = HorizontalAlignment.STRETCH;
	self._verticalAlignment = VerticalAlignment.STRETCH;
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
	assert(alignment);
	assert(alignment >= HorizontalAlignment.LEFT);
	assert(alignment <= HorizontalAlignment.STRETCH);
	self._horizontalAlignment = alignment;
end

BasicJoint.setVerticalAlignment = function(self, alignment)
	assert(alignment);
	assert(alignment >= VerticalAlignment.TOP);
	assert(alignment <= VerticalAlignment.STRETCH);
	self._verticalAlignment = alignment;
end

BasicJoint.computeLocalPosition = function(self, desiredWidth, desiredHeight, parentWidth, parentHeight)

	local paddingLeft, paddingRight, paddingTop, paddingBottom = self:getEachPadding();
	local horizontalAlignment = self:getHorizontalAlignment();
	local verticalAlignment = self:getVerticalAlignment();

	local childWidth = desiredWidth;
	if horizontalAlignment == HorizontalAlignment.STRETCH then
		childWidth = parentWidth - paddingLeft - paddingRight;
	end
	childWidth = math.max(0, childWidth);

	local childHeight = desiredHeight;
	if verticalAlignment == VerticalAlignment.STRETCH then
		childHeight = parentHeight - paddingTop - paddingBottom;
	end
	childHeight = math.max(0, childHeight);

	local x;
	if horizontalAlignment == HorizontalAlignment.LEFT then
		x = paddingLeft;
	elseif horizontalAlignment == HorizontalAlignment.CENTER then
		x = (parentWidth - childWidth) / 2 + paddingLeft - paddingRight;
	elseif horizontalAlignment == HorizontalAlignment.RIGHT then
		x = parentWidth - childWidth - paddingRight;
	elseif horizontalAlignment == HorizontalAlignment.STRETCH then
		x = paddingLeft;
	end

	local y;
	if verticalAlignment == VerticalAlignment.TOP then
		y = paddingTop;
	elseif verticalAlignment == VerticalAlignment.CENTER then
		y = (parentHeight - childHeight) / 2 + paddingTop - paddingBottom;
	elseif verticalAlignment == VerticalAlignment.BOTTOM then
		y = parentHeight - childHeight - paddingBottom;
	elseif verticalAlignment == VerticalAlignment.STRETCH then
		y = paddingTop;
	end

	return x, x + childWidth, y, y + childHeight;
end

return BasicJoint;
