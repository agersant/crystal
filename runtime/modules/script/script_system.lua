---@class ScriptSystem : System
---@field private with_runner Query
---@field private with_behavior Query
---@field private active_scripts { [Script]: ScriptRunner }
local ScriptSystem = Class("ScriptSystem", crystal.System);

ScriptSystem.init = function(self)
	self.with_runner = self:add_query({ "ScriptRunner" });
	self.with_behavior = self:add_query({ "Behavior", "ScriptRunner" });
	self.active_scripts = {};
end

ScriptSystem.run_scripts = function(self, dt)
	for runner in pairs(self.with_runner:removed_components("ScriptRunner")) do
		runner:remove_all_scripts();
	end

	for behavior, entity in pairs(self.with_behavior:added_components("Behavior")) do
		local runner = entity:component("ScriptRunner");
		local script = behavior:script();
		runner:add_script(script);
		self.active_scripts[script] = runner;
	end

	for behavior, entity in pairs(self.with_behavior:removed_components("Behavior")) do
		local script = behavior:script();
		local runner = self.active_scripts[script];
		if runner then
			runner:remove_script(script);
		end
	end

	for runner in pairs(self.with_runner:components("ScriptRunner")) do
		runner:run_all_scripts(dt);
	end
end

--#region Tests

local TestWorld = Class:test("TestWorld");

TestWorld.init = function(self)
	self.ecs = crystal.ECS:new();
	self.script_system = self.ecs:add_system(crystal.ScriptSystem);
end

TestWorld.update = function(self, dt)
	self.ecs:update(dt);
	self.script_system:run_scripts(dt);
end

crystal.test.add("Despawning entity runs deferred script functions", function()
	local world = TestWorld:new();
	local entity = world.ecs:spawn(crystal.Entity);
	entity:add_component(crystal.ScriptRunner);

	local sentinel = 0;
	entity:add_script(function(self)
		self:defer(function()
			sentinel = 1;
		end);
		self:hang();
	end);

	assert(sentinel == 0);
	world:update(0);
	assert(sentinel == 0);
	entity:despawn();
	world:update(0);
	assert(sentinel == 1);
end);

crystal.test.add("Runs behavior script", function()
	local world = TestWorld:new();
	local entity = world.ecs:spawn(crystal.Entity);
	entity:add_component(crystal.ScriptRunner);

	local sentinel = 0;
	entity:add_component(crystal.Behavior, function(self)
		sentinel = sentinel + 1;
		self:wait_frame();
		sentinel = sentinel + 10;
	end);

	assert(sentinel == 0);

	world:update(0);
	assert(sentinel == 1);

	world:update(0);
	assert(sentinel == 11);
end);

crystal.test.add("Can run multiple behaviors", function()
	local world = TestWorld:new();
	local entity = world.ecs:spawn(crystal.Entity);
	entity:add_component(crystal.ScriptRunner);

	local sentinel1 = 0;
	entity:add_component(crystal.Behavior, function(self)
		sentinel1 = sentinel1 + 1;
	end);

	local sentinel2 = 0;
	entity:add_component(crystal.Behavior, function(self)
		sentinel2 = sentinel2 + 1;
	end);

	assert(sentinel1 == 0);
	assert(sentinel2 == 0);

	world:update(0);
	assert(sentinel1 == 1);
	assert(sentinel2 == 1);
end);

crystal.test.add("Stops running script when behavior is removed", function()
	local world = TestWorld:new();
	local entity = world.ecs:spawn(crystal.Entity);
	entity:add_component(crystal.ScriptRunner);

	local sentinel = 0;
	local behavior = entity:add_component(crystal.Behavior, function(self)
		while true do
			sentinel = sentinel + 1;
			self:wait_frame();
		end
	end);

	assert(sentinel == 0);
	world:update(0);
	assert(sentinel == 1);
	entity:remove_component(behavior);
	world:update(0);
	assert(sentinel == 1);
end);

crystal.test.add("Deferred functions in Behavior are called on behavior removal", function()
	local world = TestWorld:new();
	local entity = world.ecs:spawn(crystal.Entity);
	entity:add_component(crystal.ScriptRunner);

	local sentinel = false;
	local behavior = entity:add_component(crystal.Behavior, function(self)
		self:defer(function()
			sentinel = true;
		end);
		self:hang();
	end);

	world:update(0);
	entity:remove_component(behavior);
	assert(not sentinel);
	world:update(0);
	assert(sentinel);
end);

crystal.test.add("Deferred functions in Behavior are called on despawn", function()
	local world = TestWorld:new();
	local entity = world.ecs:spawn(crystal.Entity);
	entity:add_component(crystal.ScriptRunner);

	local sentinel = false;
	entity:add_component(crystal.Behavior, function(self)
		self:defer(function()
			sentinel = true;
		end);
		self:hang();
	end);

	world:update(0);
	entity:despawn();
	assert(not sentinel);
	world:update(0);
	assert(sentinel);
end);

--#endregion

return ScriptSystem;
