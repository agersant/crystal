local Container = require("modules/ui/container");
local Joint = require("modules/ui/joint");
local Padding = require("modules/ui/padding");

---@class List : Container
---@field private axis Axis
local List = Class("List", Container);

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
List.HorizontalJoint = Class("HorizontalListJoint", ListJoint);

List.HorizontalJoint.init = function(self, parent, child)
	List.HorizontalJoint.super.init(self, parent, child);
	self._vertical_alignment = "top";
end

---@return VerticalAlignment
List.HorizontalJoint.vertical_alignment = function(self)
	return self._vertical_alignment;
end

---@param alignment VerticalAlignment
List.HorizontalJoint.set_vertical_alignment = function(self, alignment)
	assert(alignment == "top" or alignment == "center" or alignment == "bottom" or alignment == "stretch");
	self._vertical_alignment = alignment;
end

---@class VerticalListJoint : ListJoint
List.VerticalJoint = Class("VerticalListJoint", ListJoint);

---@field private _horizontal_alignment HorizontalAlignment
List.VerticalJoint.init = function(self, parent, child)
	List.VerticalJoint.super.init(self, parent, child);
	self._horizontal_alignment = "left";
end

---@return HorizontalAlignment
List.VerticalJoint.horizontal_alignment = function(self)
	return self._horizontal_alignment;
end

---@param alignment HorizontalAlignment
List.VerticalJoint.set_horizontal_alignment = function(self, alignment)
	assert(alignment == "left" or alignment == "center" or alignment == "right" or alignment == "stretch");
	self._horizontal_alignment = alignment;
end

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
	List.super.init(self, axis == "horizontal" and List.HorizontalJoint or List.VerticalJoint);
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

---@param player_index number
---@param direction Direction
---@return UIElement
List.next_focusable = function(self, from_element, player_index, direction)
	local from_index = table.index_of(self._children, from_element);
	assert(from_index);
	local delta = 0;
	if (direction == "down" and self.axis == "vertical") or (direction == "right" and self.axis == "horizontal") then
		delta = 1;
	elseif (direction == "up" and self.axis == "vertical") or (direction == "left" and self.axis == "horizontal") then
		delta = -1;
	end
	if delta == 0 then
		return List.super.next_focusable(self, from_element, player_index, direction);
	end
	local to_index = from_index + delta;
	to_element = self._children[to_index];
	while to_element do
		local next_focusable = to_element:first_focusable(player_index);
		if next_focusable then
			return next_focusable;
		end
		to_index = to_index + delta;
		to_element = self._children[to_index];
	end
end

--#region Tests

crystal.test.add("Horizontal list aligns children", function()
	local list = List.Horizontal:new();
	local a = list:add_child(crystal.UIElement:new());
	a:set_grow(1);
	local b = list:add_child(crystal.UIElement:new());
	b:set_grow(1);
	local c = list:add_child(crystal.UIElement:new());
	c:set_grow(1);
	list:update_tree(0, 90, 40);
	assert(table.equals({ a:relative_position() }, { 0, 30, 0, 0 }));
	assert(table.equals({ b:relative_position() }, { 30, 60, 0, 0 }));
	assert(table.equals({ c:relative_position() }, { 60, 90, 0, 0 }));
end);

crystal.test.add("Vertical list aligns children", function()
	local list = List.Vertical:new();
	local a = list:add_child(crystal.UIElement:new());
	a:set_grow(1);
	local b = list:add_child(crystal.UIElement:new());
	b:set_grow(1);
	local c = list:add_child(crystal.UIElement:new());
	c:set_grow(1);
	list:update_tree(0, 40, 90);
	assert(table.equals({ a:relative_position() }, { 0, 0, 0, 30 }));
	assert(table.equals({ b:relative_position() }, { 0, 0, 30, 60 }));
	assert(table.equals({ c:relative_position() }, { 0, 0, 60, 90 }));
end);

crystal.test.add("Horizontal list respects vertical alignment", function()
	local list = List.Horizontal:new();

	local a = list:add_child(crystal.UIElement:new());
	a:set_vertical_alignment("top");

	local b = list:add_child(crystal.UIElement:new());
	b:set_vertical_alignment("center");

	local c = list:add_child(crystal.UIElement:new());
	c:set_vertical_alignment("bottom");

	local d = list:add_child(crystal.UIElement:new());
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

	list:update_tree(0, nil, 40);
	assert(table.equals({ a:relative_position() }, { 0, 25, 0, 10 }));
	assert(table.equals({ b:relative_position() }, { 25, 50, 15, 25 }));
	assert(table.equals({ c:relative_position() }, { 50, 75, 30, 40 }));
	assert(table.equals({ d:relative_position() }, { 75, 100, 0, 40 }));
end);

crystal.test.add("Vertical list respects horizontal alignment", function()
	local list = List.Vertical:new();

	local a = list:add_child(crystal.UIElement:new());
	a:set_horizontal_alignment("left");

	local b = list:add_child(crystal.UIElement:new());
	b:set_horizontal_alignment("center");

	local c = list:add_child(crystal.UIElement:new());
	c:set_horizontal_alignment("right");

	local d = list:add_child(crystal.UIElement:new());
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

	list:update_tree(0, 40);
	assert(table.equals({ a:relative_position() }, { 0, 10, 0, 25 }));
	assert(table.equals({ b:relative_position() }, { 15, 25, 25, 50 }));
	assert(table.equals({ c:relative_position() }, { 30, 40, 50, 75 }));
	assert(table.equals({ d:relative_position() }, { 0, 40, 75, 100 }));
end);

crystal.test.add("Horizontal list respects padding", function()
	local list = List.Horizontal:new();

	local a = list:add_child(crystal.UIElement:new());
	a:set_vertical_alignment("top");
	a:set_padding_left(5);

	local b = list:add_child(crystal.UIElement:new());
	b:set_vertical_alignment("center");
	b:set_padding_top(5);
	b:set_padding_bottom(4);

	local c = list:add_child(crystal.UIElement:new());
	c:set_vertical_alignment("bottom");
	c:set_padding_right(10);

	local d = list:add_child(crystal.UIElement:new());
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

	list:update_tree(0);
	assert(table.equals({ a:relative_position() }, { 5, 30, 0, 10 }));
	assert(table.equals({ b:relative_position() }, { 30, 55, 16, 26 }));
	assert(table.equals({ c:relative_position() }, { 55, 80, 30, 40 }));
	assert(table.equals({ d:relative_position() }, { 100, 125, 10, 30 }));
end);

crystal.test.add("Vertical list respects padding", function()
	local list = List.Vertical:new();

	local a = list:add_child(crystal.UIElement:new());
	a:set_horizontal_alignment("left");
	a:set_padding_top(5);

	local b = list:add_child(crystal.UIElement:new());
	b:set_horizontal_alignment("center");
	b:set_padding_left(5);
	b:set_padding_right(4);

	local c = list:add_child(crystal.UIElement:new());
	c:set_horizontal_alignment("right");
	c:set_padding_bottom(10);

	local d = list:add_child(crystal.UIElement:new());
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

	list:update_tree(0);
	assert(table.equals({ a:relative_position() }, { 0, 10, 5, 30 }));
	assert(table.equals({ b:relative_position() }, { 16, 26, 30, 55 }));
	assert(table.equals({ c:relative_position() }, { 30, 40, 55, 80 }));
	assert(table.equals({ d:relative_position() }, { 10, 30, 100, 125 }));
end);


crystal.test.add("Can move focus in a list", function()
	local list = List.Vertical:new();
	local a = list:add_child(crystal.UIElement:new());
	local b = list:add_child(crystal.UIElement:new());
	local c = list:add_child(crystal.UIElement:new());
	local d = list:add_child(crystal.UIElement:new());
	a:set_focusable(true);
	b:set_focusable(true);
	d:set_focusable(true);

	assert(not a:is_focused(1));
	list:focus_tree(1);
	assert(a:is_focused(1));

	list:handle_input(1, "ui_down");
	assert(not a:is_focused(1));
	assert(b:is_focused(1));

	list:handle_input(1, "ui_down");
	assert(not b:is_focused(1));
	assert(d:is_focused(1));

	list:handle_input(1, "ui_left");
	assert(d:is_focused(1));

	list:handle_input(1, "ui_up");
	assert(not d:is_focused(1));
	assert(b:is_focused(1));
end);

crystal.test.add("Can move focus in nested lists", function()
	local row = List.Horizontal:new();

	local head = row:add_child(crystal.UIElement:new());
	head:set_focusable(true);

	local list = row:add_child(List.Vertical:new());
	local a = list:add_child(crystal.UIElement:new());
	local b = list:add_child(crystal.UIElement:new());
	local c = list:add_child(crystal.UIElement:new());
	local d = list:add_child(crystal.UIElement:new());
	a:set_focusable(true);
	b:set_focusable(true);
	d:set_focusable(true);

	local tail = row:add_child(crystal.UIElement:new());
	tail:set_focusable(true);

	row:focus_tree(1);
	assert(head:is_focused(1));

	row:handle_input(1, "ui_right");
	assert(not head:is_focused(1));
	assert(a:is_focused(1));

	row:handle_input(1, "ui_down");
	assert(b:is_focused(1));

	row:handle_input(1, "ui_right");
	assert(not b:is_focused(1));
	assert(tail:is_focused(1));
end);

--#endregion

return List;
