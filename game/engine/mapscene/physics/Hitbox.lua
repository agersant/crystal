require("engine/utils/OOP");
local Component = require("engine/ecs/Component");

local Hitbox = Class("Hitbox", Component);

Hitbox.init = function(self)
	Hitbox.super.init(self);
	self._shape = nil;
end

Hitbox.setShape = function(self, body, shape)
	if self._fixture then
		self._fixture:destroy();
		self._fixture = nil;
	end
	if shape then
		self._fixture = love.physics.newFixture(body, shape);
		self._fixture:setFilterData(CollisionFilters.HITBOX, CollisionFilters.WEAKBOX, 0);
		self._fixture:setSensor(true);
		self._fixture:setUserData(self);
	end
end

Hitbox.onBeginTouch = function(self, otherEntity)
end

Hitbox.onEndTouch = function(self, otherEntity)
end

return Hitbox;