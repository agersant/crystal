require("engine/utils/OOP");
local Terminal = require("engine/dev/cli/Terminal");
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

local drawPhysics = false;
local drawNavigation = false;

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
		return Colors.coquelicot;
	end
end

local drawShape = function(self, x, y, shape, color)
	love.graphics.push("all");
	love.graphics.translate(x, y);
	love.graphics.setLineJoin("miter");
	love.graphics.setLineStyle("rough");
	love.graphics.setLineWidth(1);

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

DebugDrawSystem.duringDebugDraw = function(self)
	local map = self._ecs:getMap();
	assert(map);

	if drawNavigation then
		map:drawNavigationMesh();
	end

	if drawPhysics then
		map:drawCollisionMesh();
		for entity in pairs(self._query:getEntities()) do
			local physicsBody = entity:getComponent(PhysicsBody):getBody();
			local x, y = physicsBody:getX(), physicsBody:getY();
			for _, fixture in ipairs(physicsBody:getFixtures()) do
				local color = pickFixtureColor(self, fixture);
				drawShape(self, x, y, fixture:getShape(), color);
			end
		end
	end
end

Terminal:registerCommand("showNavmeshOverlay", function()
	drawNavigation = true;
end);

Terminal:registerCommand("hideNavmeshOverlay", function()
	drawNavigation = false;
end);

Terminal:registerCommand("showPhysicsOverlay", function()
	drawPhysics = true;
end);

Terminal:registerCommand("hidePhysicsOverlay", function()
	drawPhysics = false;
end);

return DebugDrawSystem;
