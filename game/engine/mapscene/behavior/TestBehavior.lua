local Entity = require("engine/ecs/Entity");
local Behavior = require("engine/mapscene/behavior/Behavior");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");
local MapScene = require("engine/mapscene/MapScene");

local tests = {};

tests[#tests + 1] = {name = "Runs component scripts", gfx = "mock"};
tests[#tests].body = function()
	local scene = MapScene:new("engine/test-data/empty_map.lua");

	local Behavior1 = Class:test("Behavior1", Behavior);
	local Behavior2 = Class:test("Behavior2", Behavior);

	local sentinel1 = 0;
	local behavior1 = Behavior1:new(function(self)
		sentinel1 = sentinel1 + 1;
		self:waitFrame();
		sentinel1 = sentinel1 + 10;
	end);

	local sentinel2 = 0;
	local behavior2 = Behavior2:new(function(self)
		sentinel2 = sentinel2 + 1;
		self:waitFrame();
		sentinel2 = sentinel2 + 10;
	end);

	local entity = scene:spawn(Entity);
	entity:addComponent(ScriptRunner:new());
	entity:addComponent(behavior1);
	entity:addComponent(behavior2);

	assert(sentinel1 == 0);
	assert(sentinel2 == 0);

	scene:update(0);
	assert(sentinel1 == 1);
	assert(sentinel2 == 1);

	entity:removeComponent(behavior2);
	scene:update(0);
	assert(sentinel1 == 11);
	assert(sentinel2 == 1);
end

return tests;
