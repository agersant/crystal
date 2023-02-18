local features = require("features");
local CollisionFilters = require("mapscene/physics/CollisionFilters");
local PhysicsBody = require("mapscene/physics/PhysicsBody");
local Colors = require("resources/Colors");
local MathUtils = require("utils/MathUtils");

local DebugDrawSystem = Class("DebugDrawSystem", crystal.System);

if not features.debug_draw then
	features.stub(DebugDrawSystem);
end

local drawPhysics = false;
local drawNavigation = false;

DebugDrawSystem.init = function(self)
	self._query = self:add_query({ PhysicsBody });
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
		for entity in pairs(self._query:entities()) do
			local physicsBody = entity:component(PhysicsBody):getBody();
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

crystal.cmd.add("showNavmeshOverlay", function()
	drawNavigation = true;
end);

crystal.cmd.add("hideNavmeshOverlay", function()
	drawNavigation = false;
end);

crystal.cmd.add("showPhysicsOverlay", function()
	drawPhysics = true;
end);

crystal.cmd.add("hidePhysicsOverlay", function()
	drawPhysics = false;
end);

--#region Tests

local Hitbox = require("mapscene/physics/Hitbox");
local Collision = require("mapscene/physics/Collision");
local TouchTrigger = require("mapscene/physics/TouchTrigger");
local Weakbox = require("mapscene/physics/Weakbox");

crystal.test.add("Draws physics objects", function(context)
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");

	local entityA = scene:spawn(crystal.Entity);
	local physicsBodyA = entityA:add_component(PhysicsBody, scene:getPhysicsWorld(), "dynamic");
	entityA:setPosition(95, 55);
	entityA:add_component(Collision, physicsBodyA, 10);

	local entityB = scene:spawn(crystal.Entity);
	local physicsBodyB = entityB:add_component(PhysicsBody, scene:getPhysicsWorld(), "dynamic");
	entityB:setPosition(135, 55);
	entityB:add_component(Hitbox, physicsBodyB, love.physics.newRectangleShape(20, 20));

	local entityC = scene:spawn(crystal.Entity);
	local physicsBodyC = entityC:add_component(PhysicsBody, scene:getPhysicsWorld(), "dynamic");
	entityC:setPosition(175, 55);
	entityC:add_component(Weakbox, physicsBodyC, love.physics.newRectangleShape(20, 20));

	local entityD = scene:spawn(crystal.Entity);
	local physicsBodyD = entityD:add_component(PhysicsBody, scene:getPhysicsWorld(), "dynamic");
	entityD:setPosition(215, 55);
	local touchTrigger = TouchTrigger:new(physicsBodyD, love.physics.newCircleShape(10));
	entityD:add_component(touchTrigger);

	crystal.cmd.run("showPhysicsOverlay");
	scene:update(0);
	scene:draw();
	crystal.cmd.run("hidePhysicsOverlay");

	-- TODO Test disabled due to https://github.com/love2d/love/issues/1618
	-- context:expect_frame("test-data/TestDebugDraw/draws-physics-objects.png");
end);

crystal.test.add("Draw navigation mesh", function(context)
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");

	crystal.cmd.run("showNavmeshOverlay");
	scene:update(0);
	scene:draw();
	crystal.cmd.run("hideNavmeshOverlay");

	-- TODO Test disabled due to https://github.com/love2d/love/issues/1618
	-- context:expect_frame("test-data/TestDebugDraw/draws-navigation-mesh.png");
end);

--#endregion

return DebugDrawSystem;
