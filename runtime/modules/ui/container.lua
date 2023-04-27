local UIElement = require("modules/ui/ui_element");

---@class Container : UIElement
---@field protected _children UIElement[]
---@field protected child_joints { [UIElement]: Joint }
---@field private joint_class Class
local Container = Class("Container", UIElement);

Container.init = function(self, joint_class)
	assert(joint_class);
	Container.super.init(self);
	self._children = {};
	self.child_joints = {};
	self.joint_class = joint_class;
end

---@param child UIElement
Container.add_child = function(self, child)
	if self.child_joints[child] then
		return;
	end
	if child:parent() then
		child:remove_from_parent();
	end
	table.push(self._children, child);
	local joint = self.joint_class:new(self, child);
	self.child_joints[child] = joint;
	child:set_joint(joint);
	return child;
end

---@param child UIElement
Container.remove_child = function(self, child)
	assert(self.child_joints[child]);
	child:set_joint(nil);
	self.child_joints[child] = nil;
	for i, c in ipairs(self._children) do
		if c == child then
			table.remove(self._children, i);
		end
	end
end

---@param index integer
---@return UIElement
Container.child = function(self, index)
	return self._children[index];
end

---@return UIElement[]
Container.children = function(self)
	return table.copy(self._children);
end

---@protected
---@param dt number
Container.update = function(self, dt)
	Container.super.update(self, dt);
	local children = self:children();
	for _, child in ipairs(children) do
		child:update(dt);
	end
end

---@protected
Container.update_desired_size = function(self)
	for _, child in ipairs(self._children) do
		child:update_desired_size();
	end
	Container.super.update_desired_size(self);
end

---@protected
Container.layout = function(self)
	Container.super.layout(self);
	self:arrange_children();
	for _, child in ipairs(self._children) do
		child:layout();
	end
end

---@protected
Container.arrange_children = function(self)
	error("Not implemented");
end

---@protected
Container.draw_self = function(self)
	for _, child in ipairs(self._children) do
		child:draw();
	end
end

---@param player_index number
---@return UIElement
Container.first_focusable = function(self, player_index)
	if self.focusable and self:can_receive_input(player_index) then
		return self;
	end
	for _, child in ipairs(self._children) do
		local first_focusable = child:first_focusable(player_index);
		if first_focusable then
			return first_focusable;
		end
	end
	return nil;
end

--#region Tests

crystal.test.add("Can add and remove children", function()
	local a = UIElement:new();
	local b = UIElement:new();
	local container = Container:new(crystal.Joint);

	container:add_child(a);
	assert(a:parent() == container);
	assert(b:parent() == nil);
	container:add_child(b);
	assert(a:parent() == container);
	assert(b:parent() == container);
	container:remove_child(a);
	assert(a:parent() == nil);
	assert(b:parent() == container);

	local otherContainer = Container:new(crystal.Joint);
	otherContainer:add_child(b);
	assert(b:parent() == otherContainer);
end);

crystal.test.add("Add child returns newly added child", function()
	local a = UIElement:new();
	local container = Container:new(crystal.Joint);
	assert(container:add_child(a) == a);
end);

crystal.test.add("Can nest containers", function()
	local a = Container:new(crystal.Joint);
	local b = Container:new(crystal.Joint);
	local c = UIElement:new(crystal.Joint);
	a:add_child(b);
	b:add_child(c);
	assert(a:parent() == nil);
	assert(b:parent() == a);
	assert(c:parent() == b);
end);

crystal.test.add("Calls update on children", function()
	local a = UIElement:new(crystal.Joint);
	local b = UIElement:new(crystal.Joint);
	local sentinel = 0;
	a.update = function()
		sentinel = sentinel + 1;
	end
	b.update = function()
		sentinel = sentinel + 10;
	end
	local container = Container:new(crystal.Joint);
	container.arrange_children = function()
	end
	container:add_child(a);
	container:add_child(b);
	container:update_tree(0);
	assert(sentinel == 11)
end);

crystal.test.add("Layouts and draws children", function()
	local a = UIElement:new(crystal.Joint);
	local b = UIElement:new(crystal.Joint);
	local sentinel = 0;
	a.draw = function()
		sentinel = sentinel + 1;
	end
	b.draw = function()
		sentinel = sentinel + 10;
	end
	local container = Container:new(crystal.Joint);
	container.arrange_children = function(self)
		sentinel = 1;
	end;
	container:add_child(a);
	container:add_child(b);
	container:update_tree(0);
	assert(sentinel == 1)
	container:draw();
	assert(sentinel == 12)
end);

--#endregion

return Container;
