local MapScene = require("engine/mapscene/MapScene");
local InputDevice = require("engine/input/InputDevice");
local Script = require("engine/script/Script");
local InputListener = require("engine/mapscene/behavior/InputListener");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");
local Entity = require("engine/ecs/Entity");
local Dialog = require("arpg/field/hud/dialog/Dialog");
local DialogBox = require("arpg/field/hud/dialog/DialogBox");

local tests = {};

tests[#tests + 1] = { name = "Blocks script during dialog", gfx = "mock" };
tests[#tests].body = function()
	local scene = MapScene:new("test-data/empty_map.lua");

	local dialogBox = DialogBox:new();

	local player = scene:spawn(Entity);

	local inputDevice = InputDevice:new(1);
	inputDevice:addBinding("advanceDialog", "q");
	player:addComponent(InputListener:new(inputDevice));

	player:addComponent(ScriptRunner:new());
	player:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));

	local npc = scene:spawn(Entity);
	npc:addComponent(ScriptRunner:new());
	npc:addComponent(Dialog:new(dialogBox));

	local a;
	npc:addScript(Script:new(function(self)
		a = 1;
		self:beginDialog(player);
		self:join(self:sayLine("Test dialog."));
		a = 2;
	end));

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

tests[#tests + 1] = { name = "Can't start concurrent dialogs", gfx = "mock" };
tests[#tests].body = function()
	local scene = MapScene:new("test-data/empty_map.lua");

	local dialogBox = DialogBox:new();

	local player = scene:spawn(Entity);

	local inputDevice = InputDevice:new(1);
	inputDevice:addBinding("advanceDialog", "q");
	player:addComponent(InputListener:new(inputDevice));

	player:addComponent(ScriptRunner:new());
	player:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));

	local npc = scene:spawn(Entity);
	npc:addComponent(ScriptRunner:new());
	npc:addComponent(Dialog:new(dialogBox));

	npc:addScript(Script:new(function(self)
		self:beginDialog(player);
		self:join(self:sayLine("Test dialog."));
		self:endDialog();
	end));

	local inputDevice = player:getInputDevice();
	local frame = function(self)
		scene:update(0);
		dialogBox:update(0);
		inputDevice:flushEvents();
	end

	frame();
	assert(not Dialog:new(dialogBox):beginDialog(player));
	inputDevice:keyPressed("q");
	frame();
	inputDevice:keyReleased("q");
	frame();
	inputDevice:keyPressed("q");
	frame();
	inputDevice:keyReleased("q");
	frame();
	assert(Dialog:new(dialogBox):beginDialog(player));
end

tests[#tests + 1] = { name = "Dialog is cleaned up if entity despawns while speaking", gfx = "mock" };
tests[#tests].body = function()
	local scene = MapScene:new("test-data/empty_map.lua");

	local dialogBox = DialogBox:new();

	local player = scene:spawn(Entity);

	local inputDevice = InputDevice:new(1);
	inputDevice:addBinding("advanceDialog", "q");
	player:addComponent(InputListener:new(inputDevice));

	player:addComponent(ScriptRunner:new());
	player:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));

	local npc = scene:spawn(Entity);
	npc:addComponent(ScriptRunner:new());
	npc:addComponent(Dialog:new(dialogBox));

	npc:addScript(Script:new(function(self)
		self:beginDialog(player);
		self:join(self:sayLine("Test dialog."));
	end));

	local inputDevice = player:getInputDevice();
	local frame = function(self)
		scene:update(0);
		dialogBox:update(0);
		inputDevice:flushEvents();
	end

	frame();
	assert(not Dialog:new(dialogBox):beginDialog(player));
	npc:despawn();
	frame();
	assert(Dialog:new(dialogBox):beginDialog(player));
end

return tests;
