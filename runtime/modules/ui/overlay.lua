local Container = require("modules/ui/container");
local BasicJoint = require("modules/ui/basic_joint");

---@class OverlayJoint : BasicJoint
local OverlayJoint = Class("OverlayJoint", BasicJoint);

OverlayJoint.init = function(self, parent, child)
	OverlayJoint.super.init(self, parent, child);
	self:set_alignment("left", "top");
end

---@class Overlay : Container
local Overlay = Class("Overlay", Container);

Overlay.init = function(self)
	Overlay.super.init(self, OverlayJoint);
end

---@protected
---@return number
---@return number
Overlay.compute_desired_size = function(self)
	local width, height = 0, 0;
	for child, joint in pairs(self.child_joints) do
		local child_width, child_height = child:desired_size();
		local padding_left, padding_right, padding_top, padding_bottom = joint:padding();
		local h_align, v_align = joint:alignment();
		if h_align ~= "stretch" then
			width = math.max(width, child_width + padding_left + padding_right);
		end
		if v_align ~= "stretch" then
			height = math.max(height, child_height + padding_top + padding_bottom);
		end
	end
	return math.max(width, 0), math.max(height, 0);
end

---@protected
Overlay.arrange_children = function(self)
	local width, height = self:size();
	for _, child in ipairs(self._children) do
		local joint = self.child_joints[child];
		local child_width, child_height = child:desired_size();
		local left, right, top, bottom = joint:compute_relative_position(child_width, child_height, width, height);
		child:set_relative_position(left, right, top, bottom);
	end
end

--#region Tests

local UIElement = require("modules/ui/ui_element");

crystal.test.add("Respects alignment", function()
	local test_cases = {
		{ "left",    "top",     { 0, 60, 0, 40 } },
		{ "left",    "center",  { 0, 60, 30, 70 } },
		{ "left",    "bottom",  { 0, 60, 60, 100 } },
		{ "left",    "stretch", { 0, 60, 0, 100 } },
		{ "center",  "top",     { 20, 80, 0, 40 } },
		{ "center",  "center",  { 20, 80, 30, 70 } },
		{ "center",  "bottom",  { 20, 80, 60, 100 } },
		{ "center",  "stretch", { 20, 80, 0, 100 } },
		{ "right",   "top",     { 40, 100, 0, 40 } },
		{ "right",   "center",  { 40, 100, 30, 70 } },
		{ "right",   "bottom",  { 40, 100, 60, 100 } },
		{ "right",   "stretch", { 40, 100, 0, 100 } },
		{ "stretch", "top",     { 0, 100, 0, 40 } },
		{ "stretch", "center",  { 0, 100, 30, 70 } },
		{ "stretch", "bottom",  { 0, 100, 60, 100 } },
		{ "stretch", "stretch", { 0, 100, 0, 100 } },
	};

	for _, test_case in ipairs(test_cases) do
		local overlay = Overlay:new();

		local element = UIElement:new();
		element.compute_desired_size = function()
			return 60, 40;
		end

		overlay:add_child(element);
		element:set_horizontal_alignment(test_case[1]);
		element:set_vertical_alignment(test_case[2]);

		overlay:update_tree(0, 100, 100);
		assert(table.equals(test_case[3], { element:relative_position() }));
	end
end);

crystal.test.add("Respects padding", function()
	local test_cases = {
		{ "left",    "top",     { 2, 62, 6, 46 } },
		{ "left",    "center",  { 2, 62, 28, 68 } },
		{ "left",    "bottom",  { 2, 62, 52, 92 } },
		{ "left",    "stretch", { 2, 62, 6, 92 } },
		{ "center",  "top",     { 18, 78, 6, 46 } },
		{ "center",  "center",  { 18, 78, 28, 68 } },
		{ "center",  "bottom",  { 18, 78, 52, 92 } },
		{ "center",  "stretch", { 18, 78, 6, 92 } },
		{ "right",   "top",     { 36, 96, 6, 46 } },
		{ "right",   "center",  { 36, 96, 28, 68 } },
		{ "right",   "bottom",  { 36, 96, 52, 92 } },
		{ "right",   "stretch", { 36, 96, 6, 92 } },
		{ "stretch", "top",     { 2, 96, 6, 46 } },
		{ "stretch", "center",  { 2, 96, 28, 68 } },
		{ "stretch", "bottom",  { 2, 96, 52, 92 } },
		{ "stretch", "stretch", { 2, 96, 6, 92 } },
	};

	for _, test_case in ipairs(test_cases) do
		local overlay = Overlay:new();

		local element = UIElement:new();
		element.compute_desired_size = function()
			return 60, 40;
		end

		overlay:add_child(element);
		element:set_horizontal_alignment(test_case[1]);
		element:set_vertical_alignment(test_case[2]);
		element:set_padding(2, 4, 6, 8);

		overlay:update_tree(0, 100, 100);
		assert(table.equals(test_case[3], { element:relative_position() }));
	end
end);


--#endregion

return Overlay;
