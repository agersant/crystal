local Component = require("ecs/Component");
local PhysicsBody = require("mapscene/physics/PhysicsBody");

local Hitbox = Class("Hitbox", Component);

local updateFilterData = function(self)
	if self._fixture then
		local collideWith = self._enabled and CollisionFilters.WEAKBOX or 0;
		self._fixture:setFilterData(CollisionFilters.HITBOX, collideWith, 0);
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

Hitbox.init = function(self, physicsBody, shape)
	Hitbox.super.init(self);
	assert(physicsBody);
	assert(physicsBody:isInstanceOf(PhysicsBody));
	self._enabled = false;
	self._body = physicsBody:getBody();
	self._shape = shape;
	updateFixture(self);
end

Hitbox.setEnabled = function(self, enabled)
	self._enabled = enabled;
	updateFilterData(self);
end

Hitbox.setShape = function(self, shape)
	self._shape = shape;
	updateFixture(self);
end

Hitbox.onBeginTouch = function(self, otherComponent)
end

Hitbox.onEndTouch = function(self, otherComponent)
end

return Hitbox;
