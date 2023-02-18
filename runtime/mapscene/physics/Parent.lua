local Parent = Class("Parent", crystal.Component);

Parent.init = function(self, otherEntity)
	assert(otherEntity);
	self._parent = otherEntity;
end

Parent.getParentEntity = function(self)
	return self._parent;
end

return Parent;
