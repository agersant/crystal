local MapScene = require("engine/mapscene/MapScene");
local Script = require("engine/script/Script");
local InputListener = require("engine/mapscene/behavior/InputListener");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");
local Entity = require("engine/ecs/Entity");
local Dialog = require("arpg/field/hud/dialog/Dialog");
local HUD = require("arpg/field/hud/HUD");

local tests = {};

tests[#tests + 1] = {name = "Blocks script during dialog"};
tests[#tests].body = function()
	local scene = MapScene:new("assets/map/test/empty.lua");

	local player = scene:spawn(Entity);
	player:addComponent(ScriptRunner:new());
	player:addComponent(InputListener:new(1));
	player:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));

	local npc = scene:spawn(Entity);
	npc:addComponent(ScriptRunner:new());
	npc:addComponent(Dialog:new());

	local hud = HUD:new(scene);

	local a;
	npc:addScript(Script:new(function(self)
		a = 1;
		self:beginDialog(self, player);
		self:sayLine("Test dialog.");
		a = 2;
	end));

	scene:update(0);
	hud:update(0);
	assert(a == 1);

	local inputDevice = player:getInputDevice();
	local frame = function(self)
		scene:update(0);
		hud:update(0);
		inputDevice:flushEvents();
	end

	inputDevice:keyPressed("q");
	frame();

	inputDevice:keyReleased("q");
	frame();

	inputDevice:keyPressed("q");
	frame();

	inputDevice:keyReleased("q");
	frame();

	assert(a == 2);
end

return tests;
