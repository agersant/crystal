local Behavior = require("mapscene/behavior/Behavior");

local Actor = Class("Actor", Behavior);

Actor.init = function(self)
	Actor.super.init(self, nil);
	assert(self._script);
	self._actionThread = nil;
end

Actor.isIdle = function(self)
	return not self._actionThread or self._actionThread:isDead();
end

Actor.doAction = function(self, actionFunction)
	assert(self:isIdle());
	self._actionThread = self._script:addThreadAndRun(function(script)
			actionFunction(script);
			self._actionThread = nil;
			self:getEntity():signalAllScripts("idle");
		end);
	return self._actionThread;
end

Actor.stopAction = function(self)
	if self:isIdle() then
		return;
	end
	self._actionThread:stop();
	self._actionThread = nil;
end

--#region

local Entity = require("ecs/Entity");
local ScriptRunner = require("mapscene/behavior/ScriptRunner");
local MapScene = require("mapscene/MapScene");

crystal.test.add("Is idle after completing action", { gfx = "mock" }, function()
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
end);

crystal.test.add("Can stop action", { gfx = "mock" }, function()
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
end);

--#endregion

return Actor;
