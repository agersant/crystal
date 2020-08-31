require("engine/utils/OOP");
local Component = require("engine/ecs/Component");

local Weakbox = Class("Weakbox", Component);

Weakbox.init = function(self)
	Weakbox.super.init(self);
	self._shape = nil;
end

Weakbox.setShape = function(self, body, shape)
	assert(body);
	if self._fixture then
		self._fixture:destroy();
		self._fixture = nil;
	end
	if shape then
		self._fixture = love.physics.newFixture(body, shape, 0);
		self._fixture:setFilterData(CollisionFilters.WEAKBOX, CollisionFilters.HITBOX, 0);
		self._fixture:setSensor(true);
		self._fixture:setUserData(self);
	end
end

return Weakbox;
