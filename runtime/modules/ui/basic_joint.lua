local Joint = require("modules/ui/joint");
local Padding = require("modules/ui/padding");

---@class BasicJoint : Joint
---@field _padding Padding
---@field _horizontal_alignment HorizontalAlignment
---@field _vertical_alignment VerticalAlignment
local BasicJoint = Class("BasicJoint", Joint);

BasicJoint.init = function(self, parent, child)
	BasicJoint.super.init(self, parent, child);
	self._padding = Padding:new();
	self._horizontal_alignment = "stretch";
	self._vertical_alignment = "stretch";
	self:add_alias(self._padding);
end

---@return HorizontalAlignment
---@return VerticalAlignment
BasicJoint.alignment = function(self)
	return self._horizontal_alignment, self._vertical_alignment;
end

---@return HorizontalAlignment
BasicJoint.horizontal_alignment = function(self)
	return self._horizontal_alignment;
end

---@return VerticalAlignment
BasicJoint.vertical_alignment = function(self)
	return self._vertical_alignment;
end

---@param horizontal HorizontalAlignment
---@param vertical VerticalAlignment
BasicJoint.set_alignment = function(self, horizontal, vertical)
	self:set_horizontal_alignment(horizontal);
	self:set_vertical_alignment(vertical);
end

---@param alignment HorizontalAlignment
BasicJoint.set_horizontal_alignment = function(self, alignment)
	assert(alignment == "left" or alignment == "center" or alignment == "right" or alignment == "stretch");
	self._horizontal_alignment = alignment;
end

---@param alignment VerticalAlignment
BasicJoint.set_vertical_alignment = function(self, alignment)
	assert(alignment == "top" or alignment == "center" or alignment == "bottom" or alignment == "stretch");
	self._vertical_alignment = alignment;
end

---@param desired_width number
---@param desired_height number
---@return number
---@return number
BasicJoint.compute_desired_size = function(self, desired_width, desired_height)
	local padding_left, padding_right, padding_top, padding_bottom = self:padding();
	local width = desired_width + padding_left + padding_right;
	local height = desired_height + padding_top + padding_bottom;
	return math.max(0, width), math.max(0, height);
end

---@param desired_width number
---@param desired_height number
---@param parent_width number
---@param parent_height number
---@return number left
---@return number right
---@return number top
---@return number bottom
BasicJoint.compute_relative_position = function(self, desired_width, desired_height, parent_width, parent_height)
	local padding_left, padding_right, padding_top, padding_bottom = self:padding();
	local h_align = self:horizontal_alignment();
	local v_align = self:vertical_alignment();

	local child_width = desired_width;
	if h_align == "stretch" then
		child_width = parent_width - padding_left - padding_right;
	end
	child_width = math.max(0, child_width);

	local child_height = desired_height;
	if v_align == "stretch" then
		child_height = parent_height - padding_top - padding_bottom;
	end
	child_height = math.max(0, child_height);

	local x;
	if h_align == "left" then
		x = padding_left;
	elseif h_align == "center" then
		x = (parent_width - child_width) / 2 + padding_left - padding_right;
	elseif h_align == "right" then
		x = parent_width - child_width - padding_right;
	elseif h_align == "stretch" then
		x = padding_left;
	end

	local y;
	if v_align == "top" then
		y = padding_top;
	elseif v_align == "center" then
		y = (parent_height - child_height) / 2 + padding_top - padding_bottom;
	elseif v_align == "bottom" then
		y = parent_height - child_height - padding_bottom;
	elseif v_align == "stretch" then
		y = padding_top;
	end

	return x, x + child_width, y, y + child_height;
end

return BasicJoint;
