require("engine/utils/OOP");
local Component = require("engine/ecs/Component");
local CollisionFilters = require("engine/scene/CollisionFilters");

local Collision = Class("Collision", Component);

Collision.init = function(self, radius)
	Collision.super.init(self);
	assert(radius);
	self._radius = radius;
end

Collision.awake = function(self)
	Collision.super.awake(self);
	local body = self:getEntity():getBody();
	self._shape = love.physics.newCircleShape(self._radius);
	self._collisionFixture = love.physics.newFixture(body, self._shape);
	self._collisionFixture:setFilterData(CollisionFilters.SOLID,
                                     	CollisionFilters.GEO + CollisionFilters.SOLID + CollisionFilters.TRIGGER, 0);
	self._collisionFixture:setFriction(0);
	self._collisionFixture:setRestitution(0);
end

Collision.setCollisionRadius = function(self, radius)
	assert(radius > 0);
	if self._collisionFixture then
		self._collisionFixture:getShape():setRadius(radius);
	else
		self._radius = radius;
	end
end

Collision.getShape = function(self)
	return self._shape;
end

return Collision;
