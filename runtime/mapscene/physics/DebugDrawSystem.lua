local Features = require("dev/Features");
local System = require("ecs/System");
local AllComponents = require("ecs/query/AllComponents");
local CollisionFilters = require("mapscene/physics/CollisionFilters");
local PhysicsBody = require("mapscene/physics/PhysicsBody");
local Colors = require("resources/Colors");
local MathUtils = require("utils/MathUtils");

local DebugDrawSystem = Class("DebugDrawSystem", System);

if not Features.debugDraw then
	Features.stub(DebugDrawSystem);
end

local drawPhysics = false;
local drawNavigation = false;

DebugDrawSystem.init = function(self, ecs)
	DebugDrawSystem.super.init(self, ecs);
	self._query = AllComponents:new({ PhysicsBody });
	self:getECS():addQuery(self._query);
end

local pickFixtureColor = function(self, fixture)
	assert(fixture);
	local categories, mask, group = fixture:getFilterData();
	if bit.band(categories, CollisionFilters.TRIGGER) ~= 0 then
		return Colors.mintyGreen;
	elseif bit.band(categories, CollisionFilters.SOLID) ~= 0 then
		return Colors.jadeDust;
	elseif bit.band(categories, CollisionFilters.WEAKBOX) ~= 0 then
		return Colors.mintyGreen;
	elseif bit.band(categories, CollisionFilters.HITBOX) ~= 0 then
		return Colors.redOrange;
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

DebugDrawSystem.duringDebugDraw = function(self, viewport)
	local map = self._ecs:getMap();
	assert(map);

	if drawNavigation then
		map:drawNavigationMesh(viewport);
	end

	if drawPhysics then
		map:drawCollisionMesh(viewport);
		for entity in pairs(self._query:getEntities()) do
			local physicsBody = entity:getComponent(PhysicsBody):getBody();
			local x, y = physicsBody:getX(), physicsBody:getY();
			x = MathUtils.round(x);
			y = MathUtils.round(y);
			for _, fixture in ipairs(physicsBody:getFixtures()) do
				local color = pickFixtureColor(self, fixture);
				drawShape(self, x, y, fixture:getShape(), color);
			end
		end
	end
end

TERMINAL:addCommand("showNavmeshOverlay", function()
	drawNavigation = true;
end);

TERMINAL:addCommand("hideNavmeshOverlay", function()
	drawNavigation = false;
end);

TERMINAL:addCommand("showPhysicsOverlay", function()
	drawPhysics = true;
end);

TERMINAL:addCommand("hidePhysicsOverlay", function()
	drawPhysics = false;
end);

--#region Tests

local Entity = require("ecs/Entity");
local Hitbox = require("mapscene/physics/Hitbox");
local Collision = require("mapscene/physics/Collision");
local TouchTrigger = require("mapscene/physics/TouchTrigger");
local Weakbox = require("mapscene/physics/Weakbox");

crystal.test.add("Draws physics objects", { gfx = true }, function(context)
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");

	local entityA = scene:spawn(Entity);
	local physicsBodyA = entityA:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	entityA:setPosition(95, 55);
	entityA:addComponent(Collision:new(physicsBodyA, 10));

	local entityB = scene:spawn(Entity);
	local physicsBodyB = entityB:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	entityB:setPosition(135, 55);
	entityB:addComponent(Hitbox:new(physicsBodyB, love.physics.newRectangleShape(20, 20)));

	local entityC = scene:spawn(Entity);
	local physicsBodyC = entityC:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	entityC:setPosition(175, 55);
	entityC:addComponent(Weakbox:new(physicsBodyC, love.physics.newRectangleShape(20, 20)));

	local entityD = scene:spawn(Entity);
	local physicsBodyD = entityD:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	entityD:setPosition(215, 55);
	local touchTrigger = TouchTrigger:new(physicsBodyD, love.physics.newCircleShape(10));
	entityD:addComponent(touchTrigger);

	TERMINAL:run("showPhysicsOverlay");
	scene:update(0);
	scene:draw();
	TERMINAL:run("hidePhysicsOverlay");

	-- TODO Test disabled due to https://github.com/love2d/love/issues/1618
	-- context:expect_frame("test-data/TestDebugDraw/draws-physics-objects.png");
end);

crystal.test.add("Draw navigation mesh", { gfx = true }, function(context)
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");

	TERMINAL:run("showNavmeshOverlay");
	scene:update(0);
	scene:draw();
	TERMINAL:run("hideNavmeshOverlay");

	-- TODO Test disabled due to https://github.com/love2d/love/issues/1618
	-- context:expect_frame("test-data/TestDebugDraw/draws-navigation-mesh.png");
end);

--#endregion

return DebugDrawSystem;
