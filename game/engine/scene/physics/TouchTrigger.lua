require("engine/utils/OOP");
local DebugFlags = require("engine/dev/DebugFlags");
local Colors = require("engine/resources/Colors");
local Drawable = require("engine/scene/display/Drawable");
local CollisionFilters = require("engine/scene/CollisionFilters");

local TouchTrigger = Class("TouchTrigger", Drawable);

TouchTrigger.init = function(self, shape)
	TouchTrigger.super.init(self);
	assert(shape);
	self._shape = shape;
end

TouchTrigger.awake = function(self)
	TouchTrigger.super.awake(self);
	local body = self:getEntity():getBody();
	self._triggerFixture = love.physics.newFixture(body, self._shape);
	self._triggerFixture:setFilterData(CollisionFilters.TRIGGER, CollisionFilters.SOLID, 0);
	self._triggerFixture:setSensor(true);
end

TouchTrigger.getShape = function(self)
	return self._shape;
end

TouchTrigger.draw = function(self, x, y)
	if DebugFlags.drawPhysics then
		self:drawShape(x, y, self._shape, Colors.ecoGreen);
	end
end

return TouchTrigger;
