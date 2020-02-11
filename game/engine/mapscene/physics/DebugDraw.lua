require("engine/utils/OOP");
local DebugFlags = require("engine/dev/DebugFlags");
local Colors = require("engine/resources/Colors");
local CollisionFilters = require("engine/mapscene/CollisionFilters");
local Drawable = require("engine/mapscene/display/Drawable");

local DebugDraw = Class("DebugDraw", Drawable);

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

local drawShape = function(self, x, y, shape, color)
	love.graphics.push();
	love.graphics.translate(x, y);
	love.graphics.setColor(color:alpha(.6));
	if shape:getType() == "polygon" then
		love.graphics.polygon("fill", shape:getPoints());
	elseif shape:getType() == "circle" then
		local x, y = shape:getPoint();
		love.graphics.circle("fill", x, y, shape:getRadius(), 16);
	end
	love.graphics.setColor(color);
	if shape:getType() == "polygon" then
		love.graphics.polygon("line", shape:getPoints());
	elseif shape:getType() == "circle" then
		local x, y = shape:getPoint();
		love.graphics.circle("line", x, y, shape:getRadius(), 16);
	end
	love.graphics.pop();
end

-- PUBLIC API

DebugDraw.init = function(self, body)
	DebugDraw.super.init(self);
	self._body = body;
end

DebugDraw.draw = function(self)
	DebugDraw.super.draw(self);
	if DebugFlags.drawPhysics then
		local x, y = self._body:getX(), self._body:getY();
		for _, fixture in ipairs(self._body:getFixtures()) do
			local color = pickFixtureColor(self, fixture);
			drawShape(self, x, y, fixture:getShape(), color);
		end
	end
end

DebugDraw.getZOrder = function(self)
	return self._body:getY() + 1 / 1000;
end

return DebugDraw;
