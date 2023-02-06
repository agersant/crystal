local Component = require("ecs/Component");
local PhysicsBody = require("mapscene/physics/PhysicsBody");

local Weakbox = Class("Weakbox", Component);

local updateFilterData = function(self)
	if self._fixture then
		local collideWith = self._enabled and CollisionFilters.HITBOX or 0;
		self._fixture:setFilterData(CollisionFilters.WEAKBOX, collideWith, 0);
	end
end

local updateFixture = function(self)
	assert(self._body);
	if self._fixture then
		self._fixture:destroy();
		self._fixture = nil;
	end
	if self._shape then
		self._fixture = love.physics.newFixture(self._body, self._shape, 0);
		self._fixture:setSensor(true);
		self._fixture:setUserData(self);
		updateFilterData(self);
	end
end

Weakbox.init = function(self, physicsBody, shape)
	Weakbox.super.init(self);
	assert(physicsBody);
	assert(physicsBody:isInstanceOf(PhysicsBody));
	self._enabled = false;
	self._body = physicsBody:getBody();
	self._shape = shape;
	updateFixture(self);
end

Weakbox.setEnabled = function(self, enabled)
	self._enabled = enabled;
	updateFilterData(self);
end

Weakbox.setShape = function(self, shape)
	self._shape = shape;
	updateFixture(self);
end

return Weakbox;
