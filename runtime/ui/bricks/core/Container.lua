local Element = require("ui/bricks/core/Element");

local Container = Class("Container", Element);

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
	if child:getParent() then
		child:removeFromParent();
	end
	table.push(self._children, child);
	local joint = self._jointClass:new(self, child);
	self._childJoints[child] = joint;
	child:setJoint(joint);
	return child;
end

Container.removeChild = function(self, child)
	assert(self._childJoints[child]);
	child:setJoint(nil);
	self._childJoints[child] = nil;
	for i, c in ipairs(self._children) do
		if c == child then
			table.remove(self._children, i);
		end
	end
end

Container.getChild = function(self, index)
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

Container.updateDesiredSize = function(self)
	for _, child in ipairs(self._children) do
		child:updateDesiredSize();
	end
	Container.super.updateDesiredSize(self);
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

Container.drawSelf = function(self)
	for _, child in ipairs(self._children) do
		child:draw();
	end
end

--#region Tests

local Joint = require("ui/bricks/core/Joint");

crystal.test.add("Can add and remove children", function()
	local a = Element:new();
	local b = Element:new();
	local container = Container:new(Joint);

	container:addChild(a);
	assert(a:getParent() == container);
	assert(b:getParent() == nil);
	container:addChild(b);
	assert(a:getParent() == container);
	assert(b:getParent() == container);
	container:removeChild(a);
	assert(a:getParent() == nil);
	assert(b:getParent() == container);

	local otherContainer = Container:new(Joint);
	otherContainer:addChild(b);
	assert(b:getParent() == otherContainer);
end);

crystal.test.add("Add child returns newly added child", function()
	local a = Element:new();
	local container = Container:new(Joint);
	assert(container:addChild(a) == a);
end);

crystal.test.add("Can nest containers", function()
	local a = Container:new(Joint);
	local b = Container:new(Joint);
	local c = Element:new(Joint);
	a:addChild(b);
	b:addChild(c);
	assert(a:getParent() == nil);
	assert(b:getParent() == a);
	assert(c:getParent() == b);
end);

crystal.test.add("Calls update on children", function()
	local a = Element:new(Joint);
	local b = Element:new(Joint);
	local sentinel = 0;
	a.update = function()
		sentinel = sentinel + 1;
	end
	b.update = function()
		sentinel = sentinel + 10;
	end
	local container = Container:new(Joint);
	container.arrangeChildren = function()
	end
	container:addChild(a);
	container:addChild(b);
	container:updateTree(0);
	assert(sentinel == 11)
end);

crystal.test.add("Layouts and draws children", function()
	local a = Element:new(Joint);
	local b = Element:new(Joint);
	local sentinel = 0;
	a.draw = function()
		sentinel = sentinel + 1;
	end
	b.draw = function()
		sentinel = sentinel + 10;
	end
	local container = Container:new(Joint);
	container.arrangeChildren = function(self)
		sentinel = 1;
	end;
	container:addChild(a);
	container:addChild(b);
	container:updateTree(0);
	assert(sentinel == 1)
	container:draw();
	assert(sentinel == 12)
end);

--#endregion

return Container;
