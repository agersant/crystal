require("engine/utils/OOP");
local Component = require("engine/ecs/Component");
local CollisionFilters = require("engine/scene/CollisionFilters");

local Collision = Class("Collision", Component);

Collision.init = function(self, radius)
	Collision.super.init(self);
	assert(radius);
	self._shape = love.physics.newCircleShape(radius);
end

Collision.getCollisionFixture = function(self)
	return self._fixture;
end

Collision.setCollisionFixture = function(self, fixture)
	self._fixture = fixture;
end

Collision.setCollisionRadius = function(self, radius)
	assert(radius > 0);
	self._shape:setRadius(radius);
end

Collision.getCollisionShape = function(self)
	return self._shape;
end

return Collision;
