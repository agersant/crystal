require("engine/utils/OOP");
local DebugFlags = require("engine/dev/DebugFlags");
local Features = require("engine/dev/Features");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/query/AllComponents");
local CollisionFilters = require("engine/mapscene/physics/CollisionFilters");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");
local Colors = require("engine/resources/Colors");

local DebugDrawSystem = Class("DebugDrawSystem", System);

if not Features.debugDraw then
	Features.stub(DebugDrawSystem);
end

DebugDrawSystem.init = function(self, ecs)
	DebugDrawSystem.super.init(self, ecs);
	self._query = AllComponents:new({PhysicsBody});
	self:getECS():addQuery(self._query);
end

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

DebugDrawSystem.afterDraw = function(self, dt)
	if not DebugFlags.drawPhysics then
		return;
	end

	for entity in pairs(self._query:getEntities()) do
		local physicsBody = entity:getComponent(PhysicsBody):getBody();
		local x, y = physicsBody:getX(), physicsBody:getY();
		for _, fixture in ipairs(physicsBody:getFixtures()) do
			local color = pickFixtureColor(self, fixture);
			drawShape(self, x, y, fixture:getShape(), color);
		end
	end
end

return DebugDrawSystem;
