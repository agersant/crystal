local MapScene = require("engine/mapscene/MapScene");
local Script = require("engine/script/Script");
local InputListener = require("engine/mapscene/behavior/InputListener");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");
local Entity = require("engine/ecs/Entity");
local Dialog = require("arpg/field/hud/dialog/Dialog");
local DialogBox = require("arpg/field/hud/dialog/DialogBox");

local tests = {};

tests[#tests + 1] = {name = "Blocks script during dialog", gfx = "mock"};
tests[#tests].body = function()
	local scene = MapScene:new("engine/test-data/empty_map.lua");

	local dialogBox = DialogBox:new();

	local player = scene:spawn(Entity);
	player:addComponent(ScriptRunner:new());
	player:addComponent(InputListener:new(1));
	player:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));

	local npc = scene:spawn(Entity);
	npc:addComponent(ScriptRunner:new());
	npc:addComponent(Dialog:new(dialogBox));

	local a;
	npc:addScript(Script:new(function(self)
		a = 1;
		self:beginDialog(self, player);
		self:sayLine("Test dialog.");
		a = 2;
	end));

	local inputDevice = player:getInputDevice();
	local frame = function(self)
		scene:update(0);
		dialogBox:update(0);
		inputDevice:flushEvents();
	end

	frame();
	assert(a == 1);

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
