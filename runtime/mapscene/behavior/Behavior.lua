local Script = require("script/Script");

local Behavior = Class("Behavior", crystal.Component);

Behavior.init = function(self, entity, scriptFunction)
	Behavior.super.init(self, entity);
	assert(scriptFunction == nil or type(scriptFunction) == "function");
	self._script = Script:new(scriptFunction);
end

Behavior.getScript = function(self)
	return self._script;
end

--#region Tests

local ScriptRunner = require("mapscene/behavior/ScriptRunner");

crystal.test.add("Runs behavior script", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");

	local sentinel = 0;
	local behavior = Behavior:new(function(self)
		sentinel = sentinel + 1;
		self:waitFrame();
		sentinel = sentinel + 10;
	end);

	local entity = scene:spawn(crystal.Entity);
	entity:add_component(ScriptRunner);
	entity:add_component(behavior);

	assert(sentinel == 0);

	scene:update(0);
	assert(sentinel == 1);

	scene:update(0);
	assert(sentinel == 11);
end);

crystal.test.add("Can run multiple behaviors", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");

	local Behavior1 = Class:test("Behavior1", Behavior);
	local Behavior2 = Class:test("Behavior2", Behavior);

	local sentinel1 = 0;
	local behavior1 = Behavior1:new(function(self)
		sentinel1 = sentinel1 + 1;
	end);

	local sentinel2 = 0;
	local behavior2 = Behavior2:new(function(self)
		sentinel2 = sentinel2 + 1;
	end);

	local entity = scene:spawn(crystal.Entity);
	entity:add_component(ScriptRunner);
	entity:add_component(behavior1);
	entity:add_component(behavior2);

	assert(sentinel1 == 0);
	assert(sentinel2 == 0);

	scene:update(0);
	assert(sentinel1 == 1);
	assert(sentinel2 == 1);
end);

crystal.test.add("Stops running script when behavior is removed", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");

	local sentinel = 0;
	local behavior = Behavior:new(function(self)
		while true do
			sentinel = sentinel + 1;
			self:waitFrame();
		end
	end);

	local entity = scene:spawn(crystal.Entity);
	entity:add_component(ScriptRunner);
	entity:add_component(behavior);

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

	local sentinel = false;
	local behavior = Behavior:new(function(self)
		self:scope(function()
			sentinel = true;
		end);
		self:hang();
	end);

	local entity = scene:spawn(crystal.Entity);
	entity:add_component(ScriptRunner);
	entity:add_component(behavior);
	scene:update(0);
	entity:remove_component(behavior);
	assert(not sentinel);
	scene:update(0);
	assert(sentinel);
end);

crystal.test.add("Behavior script cleanup functions are called on despawn", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");

	local sentinel = false;
	local behavior = Behavior:new(function(self)
		self:scope(function()
			sentinel = true;
		end);
		self:hang();
	end);

	local entity = scene:spawn(crystal.Entity);
	entity:add_component(ScriptRunner);
	entity:add_component(behavior);
	scene:update(0);
	entity:despawn();
	assert(not sentinel);
	scene:update(0);
	assert(sentinel);
end);

--#endregion

return Behavior;
