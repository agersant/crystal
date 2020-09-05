require("engine/utils/OOP");
local Component = require("engine/ecs/Component");

local Hitbox = Class("Hitbox", Component);

Hitbox.init = function(self)
	Hitbox.super.init(self);
	self._shape = nil;
end

Hitbox.setShape = function(self, body, shape)
	assert(body);
	assert(shape);
	if self._fixture then
		self._fixture:destroy();
		self._fixture = nil;
	end
	self._fixture = love.physics.newFixture(body, shape, 0);
	self._fixture:setFilterData(CollisionFilters.HITBOX, CollisionFilters.WEAKBOX, 0);
	self._fixture:setSensor(true);
	self._fixture:setUserData(self);
end

Hitbox.clearShape = function(self)
	if self._fixture then
		self._fixture:destroy();
		self._fixture = nil;
	end
end

Hitbox.onBeginTouch = function(self, otherComponent)
end

Hitbox.onEndTouch = function(self, otherComponent)
end

return Hitbox;
