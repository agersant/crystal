require("engine/utils/OOP");
local Container = require("engine/ui/bricks/core/Container");
local Joint = require("engine/ui/bricks/core/Joint");
local Padding = require("engine/ui/bricks/core/Padding");
local HorizontalAlignment = require("engine/ui/bricks/core/HorizontalAlignment");
local VerticalAlignment = require("engine/ui/bricks/core/VerticalAlignment");
local Alias = require("engine/utils/Alias");

local OverlayJoint = Class("OverlayJoint", Joint);
local Overlay = Class("Overlay", Container);

OverlayJoint.init = function(self, parent, child)
	OverlayJoint.super.init(self, parent, child);
	self._padding = Padding:new();
	self._horizontalAlignment = HorizontalAlignment.LEFT;
	self._verticalAlignment = VerticalAlignment.TOP;
	Alias:add(self, self._padding);
end

OverlayJoint.getHorizontalAlignment = function(self)
	return self._horizontalAlignment;
end

OverlayJoint.getVerticalAlignment = function(self)
	return self._verticalAlignment;
end

OverlayJoint.setHorizontalAlignment = function(self, alignment)
	assert(alignment);
	assert(alignment >= HorizontalAlignment.LEFT);
	assert(alignment <= HorizontalAlignment.STRETCH);
	self._horizontalAlignment = alignment;
end

OverlayJoint.setVerticalAlignment = function(self, alignment)
	assert(alignment);
	assert(alignment >= VerticalAlignment.TOP);
	assert(alignment <= VerticalAlignment.STRETCH);
	self._verticalAlignment = alignment;
end

Overlay.init = function(self)
	Overlay.super.init(self, OverlayJoint);
end

Overlay.getDesiredSize = function(self)
	local width, height = 0, 0;
	for child, joint in pairs(self._joints) do
		local childWidth, childHeight = child:getDesiredSize();
		local paddingLeft, paddingRight, paddingTop, paddingBottom = joint:getEachPadding();
		local horizontalAlignment = joint:getHorizontalAlignment();
		local verticalAlignment = joint:getVerticalAlignment();
		if horizontalAlignment ~= HorizontalAlignment.STRETCH then
			width = math.max(width, childWidth + paddingLeft + paddingRight);
		end
		if verticalAlignment ~= VerticalAlignment.STRETCH then
			height = math.max(height, childHeight + paddingTop + paddingBottom);
		end
	end
	return math.max(width, 0), math.max(height, 0);
end

Overlay.arrangeChildren = function(self)
	local width, height = self:getSize();
	for _, child in ipairs(self._children) do
		local joint = self._joints[child];
		local childDesiredWidth, childDesiredHeight = child:getDesiredSize();
		local paddingLeft, paddingRight, paddingTop, paddingBottom = joint:getEachPadding();
		local horizontalAlignment = joint:getHorizontalAlignment();
		local verticalAlignment = joint:getVerticalAlignment();

		local childWidth = childDesiredWidth;
		if horizontalAlignment == HorizontalAlignment.STRETCH then
			childWidth = width - paddingLeft - paddingRight;
		end

		local childHeight = childDesiredHeight;
		if verticalAlignment == VerticalAlignment.STRETCH then
			childHeight = height - paddingTop - paddingBottom;
		end

		local x;
		if horizontalAlignment == HorizontalAlignment.LEFT then
			x = paddingLeft;
		elseif horizontalAlignment == HorizontalAlignment.CENTER then
			x = (width - childWidth) / 2 + paddingLeft - paddingRight;
		elseif horizontalAlignment == HorizontalAlignment.RIGHT then
			x = width - childWidth - paddingRight;
		elseif horizontalAlignment == HorizontalAlignment.STRETCH then
			x = paddingLeft;
		end

		local y;
		if verticalAlignment == VerticalAlignment.TOP then
			y = paddingTop;
		elseif verticalAlignment == VerticalAlignment.CENTER then
			y = (height - childHeight) / 2 + paddingTop - paddingBottom;
		elseif verticalAlignment == VerticalAlignment.BOTTOM then
			y = height - childHeight - paddingBottom;
		elseif verticalAlignment == VerticalAlignment.STRETCH then
			y = paddingTop;
		end

		child:setLocalPosition(x, x + childWidth, y, y + childHeight);
	end
end

return Overlay;
