require("engine/utils/OOP");
local Component = require("engine/ecs/Component");
local TableUtils = require("engine/utils/TableUtils");

local Collision = Class("Collision", Component);

Collision.init = function(self, radius)
	Collision.super.init(self);
	assert(radius);
	self._shape = love.physics.newCircleShape(radius);
	self._contactEntities = {};
end

Collision.getFixture = function(self)
	return self._fixture;
end

Collision.setFixture = function(self, fixture)
	self._fixture = fixture;
end

Collision.getShape = function(self)
	return self._shape;
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
