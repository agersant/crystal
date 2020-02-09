require("engine/utils/OOP");
local Component = require("engine/ecs/Component");

local Weakbox = Class("Weakbox", Component);

Weakbox.init = function(self)
	Weakbox.super.init(self);
	self._shape = nil;
end

Weakbox.setShape = function(self, body, shape)
	if self._fixture then
		self._fixture:destroy();
		self._fixture = nil;
	end
	if shape then
		self._fixture = love.physics.newFixture(body, shape);
		self._fixture:setFilterData(CollisionFilters.WEAKBOX, CollisionFilters.HITBOX, 0);
		self._fixture:setSensor(true);
	end
end

return Weakbox;
