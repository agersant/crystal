local PhysicsBody = require("mapscene/physics/PhysicsBody");

local TouchTrigger = Class("TouchTrigger", crystal.Component);

local updateFilterData = function(self)
	local collideWith = self._enabled and CollisionFilters.SOLID or 0;
	self._fixture:setFilterData(CollisionFilters.TRIGGER, collideWith, 0);
end

TouchTrigger.init = function(self, entity, physicsBody, shape)
	TouchTrigger.super.init(self, entity);
	assert(physicsBody);
	assert(physicsBody:is_instance_of(PhysicsBody));
	assert(shape);
	self._enabled = false;
	self._fixture = love.physics.newFixture(physicsBody:getBody(), shape, 0);
	self._fixture:setSensor(true);
	self._fixture:setUserData(self);
	updateFilterData(self);
end

TouchTrigger.setEnabled = function(self, enabled)
	self._enabled = enabled;
	updateFilterData(self);
end

TouchTrigger.onBeginTouch = function(self, otherEntity)
end

TouchTrigger.onEndTouch = function(self, otherEntity)
end

return TouchTrigger;
