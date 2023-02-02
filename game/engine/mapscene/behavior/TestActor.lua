local Entity = require("engine/ecs/Entity");
local Actor = require("engine/mapscene/behavior/Actor");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");
local MapScene = require("engine/mapscene/MapScene");

local tests = {};

tests[#tests + 1] = { name = "Is idle after completing action", gfx = "mock" };
tests[#tests].body = function()
	local scene = MapScene:new("test-data/empty_map.lua");

	local entity = scene:spawn(Entity);
	entity:addComponent(ScriptRunner:new());
	entity:addComponent(Actor:new());

	assert(entity:isIdle());
	scene:update(0);
	assert(entity:isIdle());

	entity:doAction(function(self)
		self:waitFor("s1");
	end);
	assert(not entity:isIdle());
	scene:update(0);
	assert(not entity:isIdle());

	entity:signalAllScripts("s1");
	assert(entity:isIdle());
end

tests[#tests + 1] = { name = "Can stop action", gfx = "mock" };
tests[#tests].body = function()
	local scene = MapScene:new("test-data/empty_map.lua");

	local entity = scene:spawn(Entity);
	entity:addComponent(ScriptRunner:new());
	entity:addComponent(Actor:new());

	local sentinel = false;

	scene:update(0);
	entity:doAction(function(self)
		self:waitFor("s1");
		sentinel = true;
	end);
	assert(not entity:isIdle());
	entity:stopAction();
	assert(entity:isIdle());

	entity:signalAllScripts("s1");
	assert(not sentinel);
end

return tests;
