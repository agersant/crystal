local UIElement = require("modules/ui/ui_element");

---@class Wrapper : UIElement
---@field protected _child UIElement
---@field protected child_joint Joint
---@field private joint_class Class
local Wrapper = Class("Wrapper", UIElement);

---@param joint_class Class
Wrapper.init = function(self, joint_class)
	assert(joint_class);
	Wrapper.super.init(self);
	self._child = nil;
	self.child_joint = nil;
	self.joint_class = joint_class;
end

---@return UIElement
Wrapper.child = function(self)
	return self._child;
end

---@param child UIElement
---@return UIElement
Wrapper.set_child = function(self, child)
	if self._child == child then
		return child;
	end

	if not child then
		if self._child then
			self:remove_child(self._child);
		end
		return nil;
	end

	if child:parent() then
		child:remove_from_parent();
	end
	self._child = child;
	self.child_joint = self.joint_class:new(self, child);
	child:set_joint(self.child_joint);
	return child;
end

Wrapper.remove_child = function(self)
	assert(self._child);
	local child = self._child;
	self._child:set_joint(nil);
	self._child = nil;
	self.child_joint = nil;
	return child;
end

---@protected
Wrapper.compute_desired_size = function(self)
	if self._child then
		return self._child:compute_desired_size();
	end
	return 0, 0;
end

---@protected
Wrapper.layout = function(self)
	Wrapper.super.layout(self);
	if self._child then
		self:arrange_child();
		self._child:layout();
	end
end

---@protected
Wrapper.arrange_child = function(self)
	if self._child then
		local width, height = self:size();
		self._child:set_relative_position(0, width, 0, height);
	end
end

---@protected
Wrapper.update = function(self, dt)
	Wrapper.super.update(self, dt);
	if self._child then
		return self._child:update(dt);
	end
end

---@protected
Wrapper.update_desired_size = function(self)
	if self._child then
		self._child:update_desired_size();
	end
	Wrapper.super.update_desired_size(self);
end

---@protected
Wrapper.draw_self = function(self)
	if self._child then
		self._child:draw();
	end
end

---@param player_index number
---@return UIElement
Wrapper.first_focusable = function(self, player_index)
	if self.focusable and self:can_receive_input(player_index) then
		return self;
	end
	if self._child then
		return self._child:first_focusable(player_index);
	end
	return nil;
end

--#region Tests

crystal.test.add("Can set and unset child", function()
	local a = UIElement:new();
	local wrapper = Wrapper:new(crystal.Joint);
	wrapper:set_child(a);
	assert(a:parent() == wrapper);
	wrapper:set_child(nil);
	assert(a:parent() == nil);
end);

crystal.test.add("Set child returns child", function()
	local a = UIElement:new();
	local wrapper = Wrapper:new(crystal.Joint);
	assert(wrapper:set_child(a) == a);
end);

crystal.test.add("Can nest wrappers", function()
	local a = Wrapper:new(crystal.Joint);
	local b = Wrapper:new(crystal.Joint);
	local c = UIElement:new(crystal.Joint);
	a:set_child(b);
	b:set_child(c);
	assert(a:parent() == nil);
	assert(b:parent() == a);
	assert(c:parent() == b);
end);

crystal.test.add("Layouts and draws child", function()
	local a = UIElement:new(crystal.Joint);
	local sentinel = 0;
	a.draw = function()
		sentinel = sentinel + 10;
	end
	local wrapper = Wrapper:new(crystal.Joint);
	wrapper.arrange_child = function(self)
		if self._child then
			self._child:set_relative_position(0, 0, 0, 0);
		end
		sentinel = 1;
	end;
	wrapper:set_child(a);
	wrapper:update_tree(0);
	assert(sentinel == 1)
	wrapper:draw();
	assert(sentinel == 11)
end);

--#endregion

return Wrapper;
