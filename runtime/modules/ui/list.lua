local Container = require("modules/ui/container");
local Joint = require("modules/ui/joint");
local Padding = require("modules/ui/padding");

---@class ListJoint : Joint
---@field private _padding Padding
---@field private _grow number
---@field private _shrink number
local ListJoint = Class("ListJoint", Joint);

ListJoint.init = function(self, parent, child)
	ListJoint.super.init(self, parent, child);
	self._padding = Padding:new();
	self._grow = 0;
	self._shrink = 0;
	self:add_alias(self._padding);
end

---@return number
ListJoint.grow = function(self)
	return self._grow;
end

---@return amount number
ListJoint.set_grow = function(self, amount)
	assert(amount);
	self._grow = amount;
end

---@return number
ListJoint.shrink = function(self)
	return self._shrink;
end

---@return amount number
ListJoint.set_shrink = function(self, amount)
	assert(amount);
	self._shrink = amount;
end

---@class HorizontalListJoint : ListJoint
---@field private _vertical_alignment VerticalAlignment
local HorizontalListJoint = Class("HorizontalListJoint", ListJoint);

HorizontalListJoint.init = function(self, parent, child)
	HorizontalListJoint.super.init(self, parent, child);
	self._vertical_alignment = "top";
end

---@return VerticalAlignment
HorizontalListJoint.vertical_alignment = function(self)
	return self._vertical_alignment;
end

---@param alignment VerticalAlignment
HorizontalListJoint.set_vertical_alignment = function(self, alignment)
	assert(alignment == "top" or alignment == "center" or alignment == "bottom" or alignment == "stretch");
	self._vertical_alignment = alignment;
end

---@class VerticalListJoint : ListJoint
local VerticalListJoint = Class("VerticalListJoint", ListJoint);

---@field private _horizontal_alignment HorizontalAlignment
VerticalListJoint.init = function(self, parent, child)
	VerticalListJoint.super.init(self, parent, child);
	self._horizontal_alignment = "left";
end

---@return HorizontalAlignment
VerticalListJoint.horizontal_alignment = function(self)
	return self._horizontal_alignment;
end

---@param alignment HorizontalAlignment
VerticalListJoint.set_horizontal_alignment = function(self, alignment)
	assert(alignment == "left" or alignment == "center" or alignment == "right" or alignment == "stretch");
	self._horizontal_alignment = alignment;
end

---@class List : Container
---@field private axis Axis
local List = Class("List", Container);

---@class HorizontalList : List
List.Horizontal = Class("HorizontalList", List);
List.Horizontal.init = function(self)
	List.Horizontal.super.init(self, "horizontal");
end

---@class VerticalList : List
List.Vertical = Class("VerticalList", List);
List.Vertical.init = function(self)
	List.Vertical.super.init(self, "vertical");
end

List.init = function(self, axis)
	assert(axis == "horizontal" or axis == "vertical");
	self.axis = axis;
	List.super.init(self, axis == "horizontal" and HorizontalListJoint or VerticalListJoint);
end

---@protected
---@return number
---@return number
List.compute_desired_size = function(self)
	local width, height = 0, 0;
	for child, joint in pairs(self.child_joints) do
		local child_width, child_height = child:desired_size();
		local padding_left, padding_right, padding_top, padding_bottom = joint:padding();
		if self.axis == "horizontal" then
			width = width + child_width + padding_left + padding_right;
			height = math.max(height, child_height + padding_top + padding_bottom);
		else
			height = height + child_height + padding_top + padding_bottom;
			width = math.max(width, child_width + padding_left + padding_right);
		end
	end
	return math.max(width, 0), math.max(height, 0);
end

---@protected
List.arrange_children = function(self)
	local width, height = self:size();
	local desired_width, desired_height = self:desired_size();

	local total_grow = 0;
	local total_shrink = 0;
	for _, child in ipairs(self._children) do
		local joint = self.child_joints[child];
		total_grow = total_grow + joint:grow();
		total_shrink = total_shrink + joint:shrink();
	end

	local x = 0;
	local y = 0;
	for _, child in ipairs(self._children) do
		local joint = self.child_joints[child];
		local child_desired_width, child_desired_height = child:desired_size();
		local padding_left, padding_right, padding_top, padding_bottom = joint:padding();
		local grow = joint:grow();
		local shrink = joint:shrink();

		local child_width, child_height;

		if self.axis == "horizontal" then
			x = x + padding_left;
			child_width = child_desired_width;
			if width > desired_width and grow > 0 then
				child_width = child_desired_width + (grow / total_grow) * (width - desired_width);
			elseif width < desired_width and shrink > 0 then
				child_width = child_desired_width - (shrink / total_shrink) * (desired_width - width);
			end

			local v_align = joint:vertical_alignment();
			if v_align == "stretch" then
				child_height = height - padding_top - padding_bottom;
				y = padding_top;
			elseif v_align == "top" then
				child_height = child_desired_height;
				y = padding_top;
			elseif v_align == "center" then
				child_height = child_desired_height;
				y = (height - child_height) / 2 + padding_top - padding_bottom;
			elseif v_align == "bottom" then
				child_height = child_desired_height;
				y = height - child_height - padding_bottom;
			end
		else
			y = y + padding_top;
			child_height = child_desired_height;
			if height > desired_height and grow > 0 then
				child_height = child_desired_height + (grow / total_grow) * (height - desired_height);
			elseif height < desired_height and shrink > 0 then
				child_height = child_desired_height - (shrink / total_shrink) * (desired_height - height);
			end

			local h_align = joint:horizontal_alignment();
			if h_align == "stretch" then
				child_width = width - padding_left - padding_right;
				x = padding_left;
			elseif h_align == "left" then
				child_width = child_desired_width;
				x = padding_left;
			elseif h_align == "center" then
				child_width = child_desired_width;
				x = (width - child_width) / 2 + padding_left - padding_right;
			elseif h_align == "right" then
				child_width = child_desired_width;
				x = width - child_width - padding_right;
			end
		end

		child:set_relative_position(x, x + child_width, y, y + child_height);

		if self.axis == "horizontal" then
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
	a:set_grow(1);
	local b = box:add_child(UIElement:new());
	b:set_grow(1);
	local c = box:add_child(UIElement:new());
	c:set_grow(1);
	box:update_tree(0, 90, 40);
	assert(table.equals({ a:relative_position() }, { 0, 30, 0, 0 }));
	assert(table.equals({ b:relative_position() }, { 30, 60, 0, 0 }));
	assert(table.equals({ c:relative_position() }, { 60, 90, 0, 0 }));
end);

crystal.test.add("Vertical list aligns children", function()
	local box = List.Vertical:new();
	local a = box:add_child(UIElement:new());
	a:set_grow(1);
	local b = box:add_child(UIElement:new());
	b:set_grow(1);
	local c = box:add_child(UIElement:new());
	c:set_grow(1);
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
