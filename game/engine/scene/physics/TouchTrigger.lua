require("engine/utils/OOP");
local Component = require("engine/ecs/Component");
local CollisionFilters = require("engine/scene/CollisionFilters");

local TouchTrigger = Class("TouchTrigger", Component);

TouchTrigger.init = function(self, ecs, shape)
	TouchTrigger.super.init(self, ecs);
	assert(shape);
	self._shape = shape;
end

TouchTrigger.awake = function(self)
	local body = self:getEntity():getBody();
	self._triggerFixture = love.physics.newFixture(body, self._shape);
	self._triggerFixture:setFilterData(CollisionFilters.TRIGGER, CollisionFilters.SOLID, 0);
	self._triggerFixture:setSensor(true);
end

TouchTrigger.getShape = function(self)
	return self._shape;
end

return TouchTrigger;
