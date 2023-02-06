local Goal = require("mapscene/behavior/ai/Goal");

local EntityGoal = Class("EntityGoal", Goal);

EntityGoal.init = function(self, entity, radius)
	EntityGoal.super.init(self, radius);
	self._entity = entity;
end

EntityGoal.isValid = function(self)
	return self._entity:isValid();
end

EntityGoal.getPosition = function(self)
	return self._entity:getPosition();
end

return EntityGoal;
