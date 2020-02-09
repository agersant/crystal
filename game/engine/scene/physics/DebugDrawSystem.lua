require("engine/utils/OOP");
local Features = require("engine/dev/Features");
local Entity = require("engine/ecs/Entity");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/Query/AllComponents");
local DebugDraw = require("engine/scene/physics/DebugDraw");
local PhysicsBody = require("engine/scene/physics/PhysicsBody");

local DebugDrawSystem = Class("DebugDrawSystem", System);

DebugDrawSystem.init = function(self, ecs)
	DebugDrawSystem.super.init(self, ecs);
	self._query = AllComponents:new({PhysicsBody});
	self._entityToDebugDraw = {};
	self._ecs:addQuery(self._query);
end

DebugDrawSystem.update = function(self, dt)
	if not Features.debugDraw then
		return;
	end

	for _, entity in self._query:getAddedEntities() do
		local debugDraw = self:getECS():spawn(Entity);
		debugDraw:addComponent(DebugDraw:new(entity:getBody()));
		assert(not self._entityToDebugDraw[entity]);
		self._entityToDebugDraw[entity] = debugDraw;
	end

	for _, entity in self._query:getRemovedEntities() do
		assert(self._entityToDebugDraw[entity]);
		self._entityToDebugDraw[entity]:despawn();
		self._entityToDebugDraw[entity] = nil;
	end
end

return DebugDrawSystem;
