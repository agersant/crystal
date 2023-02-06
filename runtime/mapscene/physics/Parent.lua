local Component = require("ecs/Component");

local Parent = Class("Parent", Component);

Parent.init = function(self, otherEntity)
	assert(otherEntity);
	Parent.super.init(self);
	self._parent = otherEntity;
end

Parent.getParentEntity = function(self)
	return self._parent;
end

return Parent;
