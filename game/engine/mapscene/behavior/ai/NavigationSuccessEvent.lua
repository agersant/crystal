require("engine/utils/OOP");
local Event = require("engine/ecs/Event");

local NavigationSuccessEvent = Class("NavigationSuccessEvent", Event);

NavigationSuccessEvent.init = function(self, entity, goal)
	NavigationSuccessEvent.super.init(self, entity);
	assert(goal);
	self._goal = goal;
end

NavigationSuccessEvent.getGoal = function(self)
	return self._goal;
end

return NavigationSuccessEvent;
