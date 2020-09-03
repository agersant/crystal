require("engine/utils/OOP");
local Element = require("engine/ui/bricks/core/Element");

local Wrapper = Class("Wrapper", Element);

Wrapper.init = function(self, jointClass)
	assert(jointClass);
	Wrapper.super.init(self);
	self._child = nil;
	self._joint = nil;
	self._jointClass = jointClass;
end

Wrapper.setChild = function(self, child)
	if self._child == child then
		return;
	end

	if not child then
		if self._child then
			self:removeChild(self._child);
		end
		return;
	end

	if child:getParent() then
		child:removeFromParent();
	end
	self._child = child;
	self._joint = self._jointClass:new(self, child);
	child:setJoint(self._joint);
end

Wrapper.removeChild = function(self, child)
	assert(self._child == child);
	self._child:setJoint(nil);
	self._child = nil;
	self._joint = nil;
end

Wrapper.getDesiredSize = function(self)
	if self._child then
		return self._child:getDesiredSize();
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
		local width, height = self:getSize();
		self._child:setLocalPosition(0, width, 0, height);
	end
end

Wrapper.update = function(self, dt)
	Wrapper.super.update(self, dt);
	if self._child then
		return self._child:update(dt);
	end
end

Wrapper.drawSelf = function(self)
	if self._child then
		self._child:draw();
	end
end

return Wrapper;
