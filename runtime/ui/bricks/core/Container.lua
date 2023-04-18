local UIElement = require("modules/ui/ui_element");

local Container = Class("Container", UIElement);

Container.init = function(self, jointClass)
	assert(jointClass);
	Container.super.init(self);
	self._children = {};
	self._childJoints = {};
	self._jointClass = jointClass;
end

Container.addChild = function(self, child)
	if self._childJoints[child] then
		return;
	end
	if child:parent() then
		child:remove_from_parent();
	end
	table.push(self._children, child);
	local joint = self._jointClass:new(self, child);
	self._childJoints[child] = joint;
	child:set_joint(joint);
	return child;
end

Container.remove_child = function(self, child)
	assert(self._childJoints[child]);
	child:set_joint(nil);
	self._childJoints[child] = nil;
	for i, c in ipairs(self._children) do
		if c == child then
			table.remove(self._children, i);
		end
	end
end

Container.child = function(self, index)
	return self._children[index];
end

Container.getChildren = function(self)
	return table.copy(self._children);
end

Container.update = function(self, dt)
	Container.super.update(self, dt);
	for _, child in ipairs(self._children) do
		child:update(dt);
	end
end

Container.update_desired_size = function(self)
	for _, child in ipairs(self._children) do
		child:update_desired_size();
	end
	Container.super.update_desired_size(self);
end

Container.layout = function(self)
	Container.super.layout(self);
	self:arrangeChildren();
	for _, child in ipairs(self._children) do
		child:layout();
	end
end

Container.arrangeChildren = function(self)
	error("Not implemented");
end

Container.draw_self = function(self)
	for _, child in ipairs(self._children) do
		child:draw();
	end
end

--#region Tests

crystal.test.add("Can add and remove children", function()
	local a = UIElement:new();
	local b = UIElement:new();
	local container = Container:new(crystal.Joint);

	container:addChild(a);
	assert(a:parent() == container);
	assert(b:parent() == nil);
	container:addChild(b);
	assert(a:parent() == container);
	assert(b:parent() == container);
	container:remove_child(a);
	assert(a:parent() == nil);
	assert(b:parent() == container);

	local otherContainer = Container:new(crystal.Joint);
	otherContainer:addChild(b);
	assert(b:parent() == otherContainer);
end);

crystal.test.add("Add child returns newly added child", function()
	local a = UIElement:new();
	local container = Container:new(crystal.Joint);
	assert(container:addChild(a) == a);
end);

crystal.test.add("Can nest containers", function()
	local a = Container:new(crystal.Joint);
	local b = Container:new(crystal.Joint);
	local c = UIElement:new(crystal.Joint);
	a:addChild(b);
	b:addChild(c);
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
	container.arrangeChildren = function()
	end
	container:addChild(a);
	container:addChild(b);
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
	container.arrangeChildren = function(self)
		sentinel = 1;
	end;
	container:addChild(a);
	container:addChild(b);
	container:update_tree(0);
	assert(sentinel == 1)
	container:draw();
	assert(sentinel == 12)
end);

--#endregion

return Container;
