local Script = require("modules/script/script");

---@class Behavior : Component
local Behavior = Class("Behavior", crystal.Component);

Behavior.init = function(self, script_function)
	assert(script_function == nil or type(script_function) == "function");
	self._script = Script:new(script_function);
end

Behavior.script = function(self)
	return self._script;
end

--#region Tests

local ScriptRunner = require("modules/script/script_runner");

crystal.test.add("Runs behavior script", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(crystal.Entity);
	entity:add_component(ScriptRunner);

	local sentinel = 0;
	entity:add_component(Behavior, function(self)
		sentinel = sentinel + 1;
		self:wait_frame();
		sentinel = sentinel + 10;
	end);

	assert(sentinel == 0);

	scene:update(0);
	assert(sentinel == 1);

	scene:update(0);
	assert(sentinel == 11);
end);

crystal.test.add("Can run multiple behaviors", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(crystal.Entity);
	entity:add_component(ScriptRunner);

	local sentinel1 = 0;
	entity:add_component(Behavior, function(self)
		sentinel1 = sentinel1 + 1;
	end);

	local sentinel2 = 0;
	entity:add_component(Behavior, function(self)
		sentinel2 = sentinel2 + 1;
	end);

	assert(sentinel1 == 0);
	assert(sentinel2 == 0);

	scene:update(0);
	assert(sentinel1 == 1);
	assert(sentinel2 == 1);
end);

crystal.test.add("Stops running script when behavior is removed", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(crystal.Entity);
	entity:add_component(ScriptRunner);

	local sentinel = 0;
	local behavior = entity:add_component(Behavior, function(self)
		while true do
			sentinel = sentinel + 1;
			self:wait_frame();
		end
	end);

	assert(sentinel == 0);
	scene:update(0);
	assert(sentinel == 1);
	entity:remove_component(behavior);
	scene:update(0);
	assert(sentinel == 1);
end);

crystal.test.add("Behavior script cleanup functions are called on behavior removal", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(crystal.Entity);
	entity:add_component(ScriptRunner);

	local sentinel = false;
	local behavior = entity:add_component(Behavior, function(self)
		self:defer(function()
			sentinel = true;
		end);
		self:hang();
	end);

	scene:update(0);
	entity:remove_component(behavior);
	assert(not sentinel);
	scene:update(0);
	assert(sentinel);
end);

crystal.test.add("Behavior script cleanup functions are called on despawn", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(crystal.Entity);
	entity:add_component(ScriptRunner);

	local sentinel = false;
	entity:add_component(Behavior, function(self)
		self:defer(function()
			sentinel = true;
		end);
		self:hang();
	end);

	scene:update(0);
	entity:despawn();
	assert(not sentinel);
	scene:update(0);
	assert(sentinel);
end);

--#endregion

return Behavior;
