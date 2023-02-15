local Parent = Class("Parent", crystal.Component);

Parent.init = function(self, entity, otherEntity)
	assert(otherEntity);
	Parent.super.init(self, entity);
	self._parent = otherEntity;
end

Parent.getParentEntity = function(self)
	return self._parent;
end

return Parent;
