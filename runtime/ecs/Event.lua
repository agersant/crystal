local Event = Class("Event");

Event.init = function(self, entity)
	assert(entity);
	self._entity = entity;
end

Event.getEntity = function(self)
	return self._entity;
end

return Event;
