local UIElement = require("modules/ui/ui_element");

local Wrapper = Class("Wrapper", UIElement);

Wrapper.init = function(self, jointClass)
	assert(jointClass);
	Wrapper.super.init(self);
	self._child = nil;
	self._childJoint = nil;
	self._jointClass = jointClass;
end

Wrapper.setChild = function(self, child)
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
	self._childJoint = self._jointClass:new(self, child);
	child:set_joint(self._childJoint);
	return child;
end

Wrapper.remove_child = function(self, child)
	assert(self._child == child);
	self._child:set_joint(nil);
	self._child = nil;
	self._childJoint = nil;
end

Wrapper.compute_desired_size = function(self)
	if self._child then
		return self._child:compute_desired_size();
	end
	return 0, 0;
end

Wrapper.layout = function(self)
	Wrapper.super.layout(self);
	if self._child then
		self:arrangeChild();
		self._child:layout();
	end
end

Wrapper.arrangeChild = function(self)
	if self._child then
		local width, height = self:size();
		self._child:set_relative_position(0, width, 0, height);
	end
end

Wrapper.update = function(self, dt)
	Wrapper.super.update(self, dt);
	if self._child then
		return self._child:update(dt);
	end
end

Wrapper.update_desired_size = function(self)
	if self._child then
		self._child:update_desired_size();
	end
	Wrapper.super.update_desired_size(self);
end

Wrapper.draw_self = function(self)
	if self._child then
		self._child:draw();
	end
end

--#region Tests

local Joint = require("ui/bricks/core/Joint");

crystal.test.add("Can set and unset child", function()
	local a = UIElement:new();
	local wrapper = Wrapper:new(Joint);
	wrapper:setChild(a);
	assert(a:parent() == wrapper);
	wrapper:setChild(nil);
	assert(a:parent() == nil);
end);

crystal.test.add("Set child returns child", function()
	local a = UIElement:new();
	local wrapper = Wrapper:new(Joint);
	assert(wrapper:setChild(a) == a);
end);

crystal.test.add("Can nest wrappers", function()
	local a = Wrapper:new(Joint);
	local b = Wrapper:new(Joint);
	local c = UIElement:new(Joint);
	a:setChild(b);
	b:setChild(c);
	assert(a:parent() == nil);
	assert(b:parent() == a);
	assert(c:parent() == b);
end);

crystal.test.add("Layouts and draws child", function()
	local a = UIElement:new(Joint);
	local sentinel = 0;
	a.draw = function()
		sentinel = sentinel + 10;
	end
	local wrapper = Wrapper:new(Joint);
	wrapper.arrangeChild = function(self)
		if self._child then
			self._child:set_relative_position(0, 0, 0, 0);
		end
		sentinel = 1;
	end;
	wrapper:setChild(a);
	wrapper:update_tree(0);
	assert(sentinel == 1)
	wrapper:draw();
	assert(sentinel == 11)
end);

--#endregion

return Wrapper;
