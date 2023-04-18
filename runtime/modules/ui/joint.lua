---@class Joint
---@field private _parent UIElement
---@field private _child UIElement
local Joint = Class("Joint");

Joint.init = function(self, parent, child)
	assert(parent);
	assert(child);
	assert(parent ~= child);
	self._parent = parent;
	self._child = child;
end

---@return UIElement
Joint.parent = function(self)
	return self._parent;
end

---@return UIElement
Joint.child = function(self)
	return self._child;
end

return Joint;
