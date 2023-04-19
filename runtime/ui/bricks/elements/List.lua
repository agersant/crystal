local Container = require("modules/ui/container");
local Joint = require("modules/ui/joint");
local Padding = require("modules/ui/padding");

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
	self._vertical_alignment = "top";
end

HorizontalListJoint.vertical_alignment = function(self)
	return self._vertical_alignment;
end

HorizontalListJoint.set_vertical_alignment = function(self, alignment)
	assert(alignment == "top" or alignment == "center" or alignment == "bottom" or alignment == "stretch");
	self._vertical_alignment = alignment;
end

VerticalListJoint.init = function(self, parent, child)
	VerticalListJoint.super.init(self, parent, child);
	self._horizontal_alignment = "left";
end

VerticalListJoint.horizontal_alignment = function(self)
	return self._horizontal_alignment;
end

VerticalListJoint.set_horizontal_alignment = function(self, alignment)
	assert(alignment == "left" or alignment == "center" or alignment == "right" or alignment == "stretch");
	self._horizontal_alignment = alignment;
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
	for child, joint in pairs(self.child_joints) do
		local child_width, child_height = child:desired_size();
		local padding_left, padding_right, padding_top, padding_bottom = joint:padding();
		if self._axis == "horizontal" then
			width = width + child_width + padding_left + padding_right;
			height = math.max(height, child_height + padding_top + padding_bottom);
		else
			height = height + child_height + padding_top + padding_bottom;
			width = math.max(width, child_width + padding_left + padding_right);
		end
	end
	return math.max(width, 0), math.max(height, 0);
end

List.arrange_children = function(self)
	local width, height = self:size();
	local desiredWidth, desiredHeight = self:desired_size();

	local totalGrow = 0;
	local totalShrink = 0;
	for _, child in ipairs(self._children) do
		local joint = self.child_joints[child];
		totalGrow = totalGrow + joint:getGrow();
		totalShrink = totalShrink + joint:getShrink();
	end

	local x = 0;
	local y = 0;
	for _, child in ipairs(self._children) do
		local joint = self.child_joints[child];
		local childDesiredWidth, childDesiredHeight = child:desired_size();
		local padding_left, padding_right, padding_top, padding_bottom = joint:padding();
		local grow = joint:getGrow();
		local shrink = joint:getShrink();

		local child_width, child_height;

		if self._axis == "horizontal" then
			x = x + padding_left;
			child_width = childDesiredWidth;
			if width > desiredWidth and grow > 0 then
				child_width = childDesiredWidth + (grow / totalGrow) * (width - desiredWidth);
			elseif width < desiredWidth and shrink > 0 then
				child_width = childDesiredWidth - (shrink / totalShrink) * (desiredWidth - width);
			end

			local verticalAlignment = joint:vertical_alignment();
			if verticalAlignment == "stretch" then
				child_height = height - padding_top - padding_bottom;
				y = padding_top;
			elseif verticalAlignment == "top" then
				child_height = childDesiredHeight;
				y = padding_top;
			elseif verticalAlignment == "center" then
				child_height = childDesiredHeight;
				y = (height - child_height) / 2 + padding_top - padding_bottom;
			elseif verticalAlignment == "bottom" then
				child_height = childDesiredHeight;
				y = height - child_height - padding_bottom;
			end
		else
			y = y + padding_top;
			child_height = childDesiredHeight;
			if height > desiredHeight and grow > 0 then
				child_height = childDesiredHeight + (grow / totalGrow) * (height - desiredHeight);
			elseif height < desiredHeight and shrink > 0 then
				child_height = childDesiredHeight - (shrink / totalShrink) * (desiredHeight - height);
			end

			local horizontalAlignment = joint:horizontal_alignment();
			if horizontalAlignment == "stretch" then
				child_width = width - padding_left - padding_right;
				x = padding_left;
			elseif horizontalAlignment == "left" then
				child_width = childDesiredWidth;
				x = padding_left;
			elseif horizontalAlignment == "center" then
				child_width = childDesiredWidth;
				x = (width - child_width) / 2 + padding_left - padding_right;
			elseif horizontalAlignment == "right" then
				child_width = childDesiredWidth;
				x = width - child_width - padding_right;
			end
		end

		child:set_relative_position(x, x + child_width, y, y + child_height);

		if self._axis == "horizontal" then
			x = x + child_width + padding_right;
		else
			y = y + child_height + padding_bottom;
		end
	end
end

--#region Tests

local UIElement = require("modules/ui/ui_element");

crystal.test.add("Horizontal list aligns children", function()
	local box = List.Horizontal:new();
	local a = box:add_child(UIElement:new());
	a:setGrow(1);
	local b = box:add_child(UIElement:new());
	b:setGrow(1);
	local c = box:add_child(UIElement:new());
	c:setGrow(1);
	box:update_tree(0, 90, 40);
	assert(table.equals({ a:relative_position() }, { 0, 30, 0, 0 }));
	assert(table.equals({ b:relative_position() }, { 30, 60, 0, 0 }));
	assert(table.equals({ c:relative_position() }, { 60, 90, 0, 0 }));
end);

crystal.test.add("Vertical list aligns children", function()
	local box = List.Vertical:new();
	local a = box:add_child(UIElement:new());
	a:setGrow(1);
	local b = box:add_child(UIElement:new());
	b:setGrow(1);
	local c = box:add_child(UIElement:new());
	c:setGrow(1);
	box:update_tree(0, 40, 90);
	assert(table.equals({ a:relative_position() }, { 0, 0, 0, 30 }));
	assert(table.equals({ b:relative_position() }, { 0, 0, 30, 60 }));
	assert(table.equals({ c:relative_position() }, { 0, 0, 60, 90 }));
end);

crystal.test.add("Horizontal list respects vertical alignment", function()
	local box = List.Horizontal:new();

	local a = box:add_child(UIElement:new());
	a:set_vertical_alignment("top");

	local b = box:add_child(UIElement:new());
	b:set_vertical_alignment("center");

	local c = box:add_child(UIElement:new());
	c:set_vertical_alignment("bottom");

	local d = box:add_child(UIElement:new());
	d:set_vertical_alignment("stretch");

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

	local a = box:add_child(UIElement:new());
	a:set_horizontal_alignment("left");

	local b = box:add_child(UIElement:new());
	b:set_horizontal_alignment("center");

	local c = box:add_child(UIElement:new());
	c:set_horizontal_alignment("right");

	local d = box:add_child(UIElement:new());
	d:set_horizontal_alignment("stretch");

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

	local a = box:add_child(UIElement:new());
	a:set_vertical_alignment("top");
	a:set_padding_left(5);

	local b = box:add_child(UIElement:new());
	b:set_vertical_alignment("center");
	b:set_padding_top(5);
	b:set_padding_bottom(4);

	local c = box:add_child(UIElement:new());
	c:set_vertical_alignment("bottom");
	c:set_padding_right(10);

	local d = box:add_child(UIElement:new());
	d:set_vertical_alignment("stretch");
	d:set_padding(10);

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

	local a = box:add_child(UIElement:new());
	a:set_horizontal_alignment("left");
	a:set_padding_top(5);

	local b = box:add_child(UIElement:new());
	b:set_horizontal_alignment("center");
	b:set_padding_left(5);
	b:set_padding_right(4);

	local c = box:add_child(UIElement:new());
	c:set_horizontal_alignment("right");
	c:set_padding_bottom(10);

	local d = box:add_child(UIElement:new());
	d:set_horizontal_alignment("stretch");
	d:set_padding(10);

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
