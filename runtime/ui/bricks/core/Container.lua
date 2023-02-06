local Element = require("ui/bricks/core/Element");
local TableUtils = require("utils/TableUtils");

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
	table.insert(self._children, child);
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
	return TableUtils.shallowCopy(self._children);
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

return Container;
