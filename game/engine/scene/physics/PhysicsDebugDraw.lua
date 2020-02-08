require("engine/utils/OOP");
local DebugFlags = require("engine/dev/DebugFlags");
local Colors = require("engine/resources/Colors");
local CollisionFilters = require("engine/scene/CollisionFilters");
local Drawable = require("engine/scene/display/Drawable");

local PhysicsDebugDraw = Class("PhysicsDebugDraw", Drawable);

-- IMPLEMENTATION

local pickFixtureColor = function(self, fixture)
	assert(fixture);
	local categories, mask, group = fixture:getFilterData();
	if bit.band(categories, CollisionFilters.TRIGGER) ~= 0 then
		return Colors.ecoGreen;
	elseif bit.band(categories, CollisionFilters.SOLID) ~= 0 then
		return Colors.cyan;
	elseif bit.band(categories, CollisionFilters.WEAKBOX) ~= 0 then
		return Colors.ecoGreen;
	elseif bit.band(categories, CollisionFilters.HITBOX) ~= 0 then
		return Colors.strawberry;
	end
end

-- PUBLIC API

PhysicsDebugDraw.init = function(self, body)
	PhysicsDebugDraw.super.init(self);
	self._body = body;
end

PhysicsDebugDraw.draw = function(self)
	PhysicsDebugDraw.super.draw(self);
	if DebugFlags.drawPhysics then
		local x, y = self._body:getX(), self._body:getY();
		for _, fixture in ipairs(self._body:getFixtures()) do
			local color = pickFixtureColor(self, fixture);
			self:drawShape(x, y, fixture:getShape(), color);
		end
	end
end

PhysicsDebugDraw.getZOrder = function(self)
	return self._body:getY() + 1 / 1000;
end

return PhysicsDebugDraw;
