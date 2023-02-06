local Element = require("ui/bricks/core/Element");

local Wrapper = Class("Wrapper", Element);

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
			self:removeChild(self._child);
		end
		return nil;
	end

	if child:getParent() then
		child:removeFromParent();
	end
	self._child = child;
	self._childJoint = self._jointClass:new(self, child);
	child:setJoint(self._childJoint);
	return child;
end

Wrapper.removeChild = function(self, child)
	assert(self._child == child);
	self._child:setJoint(nil);
	self._child = nil;
	self._childJoint = nil;
end

Wrapper.computeDesiredSize = function(self)
	if self._child then
		return self._child:computeDesiredSize();
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

Wrapper.updateDesiredSize = function(self)
	if self._child then
		self._child:updateDesiredSize();
	end
	Wrapper.super.updateDesiredSize(self);
end

Wrapper.drawSelf = function(self)
	if self._child then
		self._child:draw();
	end
end

return Wrapper;
