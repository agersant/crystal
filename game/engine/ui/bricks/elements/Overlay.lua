require("engine/utils/OOP");
local Container = require("engine/ui/bricks/core/Container");
local Padding = require("engine/ui/bricks/core/Padding");
local HorizontalAlignment = require("engine/ui/bricks/core/HorizontalAlignment");
local VerticalAlignment = require("engine/ui/bricks/core/VerticalAlignment");
local BasicJoint = require("engine/ui/bricks/core/BasicJoint");

local OverlayJoint = Class("OverlayJoint", BasicJoint);
local Overlay = Class("Overlay", Container);

OverlayJoint.init = function(self, parent, child)
	OverlayJoint.super.init(self, parent, child);
	self._horizontalAlignment = HorizontalAlignment.LEFT;
	self._verticalAlignment = VerticalAlignment.TOP;
end

Overlay.init = function(self)
	Overlay.super.init(self, OverlayJoint);
end

Overlay.computeDesiredSize = function(self)
	local width, height = 0, 0;
	for child, joint in pairs(self._childJoints) do
		local childWidth, childHeight = child:getDesiredSize();
		local paddingLeft, paddingRight, paddingTop, paddingBottom = joint:getEachPadding();
		local horizontalAlignment, verticalAlignment = joint:getAlignment();
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
		local joint = self._childJoints[child];
		local childWidth, childHeight = child:getDesiredSize();
		local left, right, top, bottom = joint:computeLocalPosition(childWidth, childHeight, width, height);
		child:setLocalPosition(left, right, top, bottom);
	end
end

return Overlay;
