local CLI = require("engine/dev/cli/CLI");
local DebugFlags = require("engine/dev/DebugFlags");
local Persistence = require("engine/persistence/Persistence");
local Scene = require("engine/Scene");
local Entity = require("engine/ecs/Entity");
local Module = require("engine/Module");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");

local loadMap = function(mapName)
	Persistence:getSaveData():save();
	local sceneClass = Module:getCurrent().classes.MapScene;
	local newScene = sceneClass:new("assets/map/" .. mapName .. ".lua");
	Scene:setCurrent(newScene);
end

CLI:addCommand("loadMap mapName:string", loadMap);

local testMap = function()
	loadMap("dev");
end

CLI:addCommand("testMap", testMap);

local setDrawPhysicsOverlay = function(draw)
	DebugFlags.drawPhysics = draw;
end

CLI:addCommand("showPhysicsOverlay", function()
	setDrawPhysicsOverlay(true);
end);
CLI:addCommand("hidePhysicsOverlay", function()
	setDrawPhysicsOverlay(false);
end);

local setDrawNavmeshOverlay = function(draw)
	DebugFlags.drawNavmesh = draw;
end

CLI:addCommand("showNavmeshOverlay", function()
	setDrawNavmeshOverlay(true);
end);
CLI:addCommand("hideNavmeshOverlay", function()
	setDrawNavmeshOverlay(false);
end);

local spawn = function(className)
	local currentScene = Scene:getCurrent();
	local player = currentScene:getPartyMemberEntities()[1];
	assert(player);

	local map = currentScene:getMap();
	assert(map);

	local class = Class:getByName(className);
	assert(class);
	assert(class:isInstanceOf(Entity));
	local entity = currentScene:spawn(class);

	local physicsBody = entity:getComponent(PhysicsBody);
	if physicsBody then
		local x, y = player:getPosition();
		local angle = math.random(2 * math.pi);
		local radius = 40;
		x = x + radius * math.cos(angle);
		y = y + radius * math.sin(angle);
		x, y = map:getNearestPointOnNavmesh(x, y);
		physicsBody:setPosition(x, y);
	end
end

CLI:addCommand("spawn className:string", spawn);