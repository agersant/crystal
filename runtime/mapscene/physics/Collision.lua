local Component = require("ecs/Component");
local PhysicsBody = require("mapscene/physics/PhysicsBody");
local TableUtils = require("utils/TableUtils");

local Collision = Class("Collision", Component);

local updateFilterData = function(self)
	local collideWith = 0;
	if self._enabled then
		collideWith = collideWith + CollisionFilters.GEO;
		if self._collideWithOthers then
			collideWith = collideWith + CollisionFilters.SOLID;
		end
		collideWith = collideWith + CollisionFilters.TRIGGER;
	end
	self._fixture:setFilterData(CollisionFilters.SOLID, collideWith, 0);
end

local getState = function(self)
	return {
		collideWithOthers = self._collideWithOthers,
		friction = self._fixture:getFriction(),
		restitution = self._fixture:getRestitution(),
	};
end

local setState = function(self, state)
	self:setCollideWithOthers(state.collideWithOthers);
	self:setFriction(state.friction);
	self:setRestitution(state.restitution);
end

Collision.init = function(self, physicsBody, radius)
	Collision.super.init(self);
	assert(physicsBody);
	assert(physicsBody:isInstanceOf(PhysicsBody));
	assert(radius);
	self._contactEntities = {};
	self._enabled = false;
	self._collideWithOthers = true;

	local shape = love.physics.newCircleShape(radius);
	self._fixture = love.physics.newFixture(physicsBody:getBody(), shape, 0);
	self._fixture:setUserData(self);
	self._fixture:setFriction(0);
	self._fixture:setRestitution(0);
	updateFilterData(self);
end

Collision.pushCollisionState = function(self)
	local state = getState(self);
	return function()
		setState(self, state);
	end
end

Collision.setEnabled = function(self, enabled)
	self._enabled = enabled;
	updateFilterData(self);
end

Collision.setCollideWithOthers = function(self, collide)
	self._collideWithOthers = collide;
	updateFilterData(self);
end

Collision.setFriction = function(self, friction)
	self._fixture:setFriction(friction);
end

Collision.setRestitution = function(self, restitution)
	self._fixture:setRestitution(restitution);
end

Collision.onBeginTouch = function(self, otherComponent)
	local entity = otherComponent:getEntity();
	self._contactEntities[entity] = true;
end

Collision.onEndTouch = function(self, otherComponent)
	local entity = otherComponent:getEntity();
	self._contactEntities[entity] = nil;
end

Collision.getContactEntities = function(self, otherComponent)
	return TableUtils.shallowCopy(self._contactEntities);
end

return Collision;
