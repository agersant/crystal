local BricksUtils = require("ui/bricks/core/BricksUtils");
local Container = require("ui/bricks/core/Container");
local Joint = require("modules/ui/joint");
local Padding = require("ui/bricks/core/Padding");

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
	self:add_alias(self._padding);
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

List.compute_desired_size = function(self)
	local width, height = 0, 0;
	for child, joint in pairs(self._childJoints) do
		local childWidth, childHeight = child:desired_size();
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
	local width, height = self:size();
	local desiredWidth, desiredHeight = self:desired_size();

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
		local childDesiredWidth, childDesiredHeight = child:desired_size();
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

		child:set_relative_position(x, x + childWidth, y, y + childHeight);

		if self._axis == "horizontal" then
			x = x + childWidth + paddingRight;
		else
			y = y + childHeight + paddingBottom;
		end
	end
end

--#region Tests

local UIElement = require("modules/ui/ui_element");

crystal.test.add("Horizontal list aligns children", function()
	local box = List.Horizontal:new();
	local a = box:addChild(UIElement:new());
	a:setGrow(1);
	local b = box:addChild(UIElement:new());
	b:setGrow(1);
	local c = box:addChild(UIElement:new());
	c:setGrow(1);
	box:update_tree(0, 90, 40);
	assert(table.equals({ a:relative_position() }, { 0, 30, 0, 0 }));
	assert(table.equals({ b:relative_position() }, { 30, 60, 0, 0 }));
	assert(table.equals({ c:relative_position() }, { 60, 90, 0, 0 }));
end);

crystal.test.add("Vertical list aligns children", function()
	local box = List.Vertical:new();
	local a = box:addChild(UIElement:new());
	a:setGrow(1);
	local b = box:addChild(UIElement:new());
	b:setGrow(1);
	local c = box:addChild(UIElement:new());
	c:setGrow(1);
	box:update_tree(0, 40, 90);
	assert(table.equals({ a:relative_position() }, { 0, 0, 0, 30 }));
	assert(table.equals({ b:relative_position() }, { 0, 0, 30, 60 }));
	assert(table.equals({ c:relative_position() }, { 0, 0, 60, 90 }));
end);

crystal.test.add("Horizontal list respects vertical alignment", function()
	local box = List.Horizontal:new();

	local a = box:addChild(UIElement:new());
	a:setVerticalAlignment("top");

	local b = box:addChild(UIElement:new());
	b:setVerticalAlignment("center");

	local c = box:addChild(UIElement:new());
	c:setVerticalAlignment("bottom");

	local d = box:addChild(UIElement:new());
	d:setVerticalAlignment("stretch");

	a.compute_desired_size = function()
		return 25, 10;
	end
	b.compute_desired_size = function()
		return 25, 10;
	end
	c.compute_desired_size = function()
		return 25, 10;
	end
	d.compute_desired_size = function()
		return 25, 10;
	end

	box:update_tree(0, nil, 40);
	assert(table.equals({ a:relative_position() }, { 0, 25, 0, 10 }));
	assert(table.equals({ b:relative_position() }, { 25, 50, 15, 25 }));
	assert(table.equals({ c:relative_position() }, { 50, 75, 30, 40 }));
	assert(table.equals({ d:relative_position() }, { 75, 100, 0, 40 }));
end);

crystal.test.add("Vertical list respects horizontal alignment", function()
	local box = List.Vertical:new();

	local a = box:addChild(UIElement:new());
	a:setHorizontalAlignment("left");

	local b = box:addChild(UIElement:new());
	b:setHorizontalAlignment("center");

	local c = box:addChild(UIElement:new());
	c:setHorizontalAlignment("right");

	local d = box:addChild(UIElement:new());
	d:setHorizontalAlignment("stretch");

	a.compute_desired_size = function()
		return 10, 25;
	end
	b.compute_desired_size = function()
		return 10, 25;
	end
	c.compute_desired_size = function()
		return 10, 25;
	end
	d.compute_desired_size = function()
		return 10, 25;
	end

	box:update_tree(0, 40);
	assert(table.equals({ a:relative_position() }, { 0, 10, 0, 25 }));
	assert(table.equals({ b:relative_position() }, { 15, 25, 25, 50 }));
	assert(table.equals({ c:relative_position() }, { 30, 40, 50, 75 }));
	assert(table.equals({ d:relative_position() }, { 0, 40, 75, 100 }));
end);

crystal.test.add("Horizontal list respects padding", function()
	local box = List.Horizontal:new();

	local a = box:addChild(UIElement:new());
	a:setVerticalAlignment("top");
	a:setLeftPadding(5);

	local b = box:addChild(UIElement:new());
	b:setVerticalAlignment("center");
	b:setTopPadding(5);
	b:setBottomPadding(4);

	local c = box:addChild(UIElement:new());
	c:setVerticalAlignment("bottom");
	c:setRightPadding(10);

	local d = box:addChild(UIElement:new());
	d:setVerticalAlignment("stretch");
	d:setAllPadding(10);

	a.compute_desired_size = function()
		return 25, 10;
	end
	b.compute_desired_size = function()
		return 25, 10;
	end
	c.compute_desired_size = function()
		return 25, 10;
	end
	d.compute_desired_size = function()
		return 25, 20;
	end

	box:update_tree(0);
	assert(table.equals({ a:relative_position() }, { 5, 30, 0, 10 }));
	assert(table.equals({ b:relative_position() }, { 30, 55, 16, 26 }));
	assert(table.equals({ c:relative_position() }, { 55, 80, 30, 40 }));
	assert(table.equals({ d:relative_position() }, { 100, 125, 10, 30 }));
end);

crystal.test.add("Vertical list respects padding", function()
	local box = List.Vertical:new();

	local a = box:addChild(UIElement:new());
	a:setHorizontalAlignment("left");
	a:setTopPadding(5);

	local b = box:addChild(UIElement:new());
	b:setHorizontalAlignment("center");
	b:setLeftPadding(5);
	b:setRightPadding(4);

	local c = box:addChild(UIElement:new());
	c:setHorizontalAlignment("right");
	c:setBottomPadding(10);

	local d = box:addChild(UIElement:new());
	d:setHorizontalAlignment("stretch");
	d:setAllPadding(10);

	a.compute_desired_size = function()
		return 10, 25;
	end
	b.compute_desired_size = function()
		return 10, 25;
	end
	c.compute_desired_size = function()
		return 10, 25;
	end
	d.compute_desired_size = function()
		return 20, 25;
	end

	box:update_tree(0);
	assert(table.equals({ a:relative_position() }, { 0, 10, 5, 30 }));
	assert(table.equals({ b:relative_position() }, { 16, 26, 30, 55 }));
	assert(table.equals({ c:relative_position() }, { 30, 40, 55, 80 }));
	assert(table.equals({ d:relative_position() }, { 10, 30, 100, 125 }));
end);

--#endregion

return List;
