local Joint = Class("Joint");

Joint.init = function(self, parent, child)
	assert(parent);
	assert(child);
	assert(parent ~= child);
	self._parent = parent;
	self._child = child;
end

Joint.getParent = function(self)
	return self._parent;
end

Joint.getChild = function(self)
	return self._child;
end

return Joint;
