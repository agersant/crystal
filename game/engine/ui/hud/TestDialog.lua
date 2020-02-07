local MapScene = require("engine/scene/MapScene");
local Script = require("engine/script/Script");
local Controller = require("engine/scene/behavior/Controller");
local ScriptRunner = require("engine/scene/behavior/ScriptRunner");
local Entity = require("engine/ecs/Entity");
local Dialog = require("engine/ui/hud/Dialog");

local tests = {};

tests[#tests + 1] = {name = "Blocks script during say"};
tests[#tests].body = function()
	local scene = MapScene:new("assets/map/test/empty.lua");
	local player = scene:spawn(Entity);
	player:addComponent(ScriptRunner:new(scene));
	player:addComponent(Controller:new(scene, function()
	end));
	-- TODO Fix me
	-- player:addComponent(InputDrivenController:new(player, function()
	-- end, 1));

	-- local dialog = Dialog:new();
	-- local a = 0;
	-- local script = Script:new(function(self)
	-- 	a = 1;
	-- 	dialog:open(self, player);
	-- 	dialog:say("Test dialog.");
	-- 	a = 2;
	-- end);
	-- script:update(0);
	-- assert(a == 1);
	-- dialog:signal("+advanceDialog");
	-- dialog:signal("+advanceDialog");
	-- script:update(0);
	-- assert(a == 2);
end

return tests;
