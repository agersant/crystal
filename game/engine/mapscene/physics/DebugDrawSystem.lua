require("engine/utils/OOP");
local Features = require("engine/dev/Features");
local Entity = require("engine/ecs/Entity");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/query/AllComponents");
local DebugDraw = require("engine/mapscene/physics/DebugDraw");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");

local DebugDrawSystem = Class("DebugDrawSystem", System);

DebugDrawSystem.init = function(self, ecs)
	DebugDrawSystem.super.init(self, ecs);
	self._query = AllComponents:new({PhysicsBody});
	self._entityToDebugDraw = {};
	self:getECS():addQuery(self._query);
end

DebugDrawSystem.beforeDraw = function(self, dt)
	if not Features.debugDraw then
		return;
	end

	for entity in pairs(self._query:getAddedEntities()) do
		local physicsBody = entity:getComponent(PhysicsBody):getBody();
		local debugDraw = self:getECS():spawn(Entity);
		debugDraw:addComponent(DebugDraw:new(physicsBody));
		assert(not self._entityToDebugDraw[entity]);
		self._entityToDebugDraw[entity] = debugDraw;
	end

	for entity in pairs(self._query:getRemovedEntities()) do
		assert(self._entityToDebugDraw[entity]);
		self._entityToDebugDraw[entity]:despawn();
		self._entityToDebugDraw[entity] = nil;
	end
end

return DebugDrawSystem;
