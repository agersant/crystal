require("engine/utils/OOP");
local AllComponents = require("engine/ecs/query/AllComponents");
local System = require("engine/ecs/System");
local Behavior = require("engine/mapscene/behavior/Behavior");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");

local BehaviorSystem = Class("BehaviorSystem", System);

BehaviorSystem.init = function(self, ecs)
	BehaviorSystem.super.init(self, ecs);
	self._activeEntities = {};
	self._query = AllComponents:new({Behavior, ScriptRunner});
	self._ecs:addQuery(self._query);
end

BehaviorSystem.beforeScripts = function(self, dt)
	for behavior, entity in pairs(self._query:getAddedComponents(Behavior)) do
		local scriptRunner = entity:getComponent(ScriptRunner);
		assert(scriptRunner);
		local script = behavior:getScript();
		assert(script);
		scriptRunner:addScript(script);
		if not self._activeEntities[entity] then
			self._activeEntities[entity] = {scriptRunner = scriptRunner};
		end
		self._activeEntities[entity][behavior] = script;
	end

	for behavior, entity in pairs(self._query:getRemovedComponents(Behavior)) do
		assert(self._activeEntities[entity]);
		assert(self._activeEntities[entity][behavior]);
		local activeEntity = self._activeEntities[entity];
		activeEntity.scriptRunner:removeScript(activeEntity[behavior]);
		self._activeEntities[entity][behavior] = nil;
	end

	for entity in pairs(self._query:getRemovedEntities()) do
		for _, script in pairs(self._activeEntities[entity]) do
			self._activeEntities[entity].scriptRunner:removeScript(script);
		end
		self._activeEntities[entity] = nil;
	end
end

return BehaviorSystem;
