require("engine/utils/OOP");
local Event = require("engine/ecs/Event");

local NavigationFailureEvent = Class("NavigationFailureEvent", Event);

NavigationFailureEvent.init = function(self, entity, goal)
	NavigationFailureEvent.super.init(self, entity);
	assert(goal);
	self._goal = goal;
end

NavigationFailureEvent.getGoal = function(self)
	return self._goal;
end

return NavigationFailureEvent;
