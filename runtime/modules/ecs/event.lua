---@class Event
local Event = Class("Event");

Event.init = function(self)
	-- self._entity setup by Entity:create_event
end

---@return Entity
Event.entity = function(self)
	return self._entity;
end

return Event;
