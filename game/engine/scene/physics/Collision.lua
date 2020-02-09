require("engine/utils/OOP");
local Component = require("engine/ecs/Component");

local Collision = Class("Collision", Component);

Collision.init = function(self, radius)
	Collision.super.init(self);
	assert(radius);
	self._shape = love.physics.newCircleShape(radius);
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

return Collision;
