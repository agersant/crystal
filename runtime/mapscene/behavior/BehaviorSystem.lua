local AllComponents = require("ecs/query/AllComponents");
local System = require("ecs/System");
local Behavior = require("mapscene/behavior/Behavior");
local ScriptRunner = require("mapscene/behavior/ScriptRunner");
local Script = require("script/Script");

local BehaviorSystem = Class("BehaviorSystem", System);

BehaviorSystem.init = function(self, ecs)
	BehaviorSystem.super.init(self, ecs);
	self._activeEntities = {};
	self._query = AllComponents:new({ Behavior, ScriptRunner });
	self._ecs:addQuery(self._query);
end

BehaviorSystem.beforeScripts = function(self, dt)
	for behavior, entity in pairs(self._query:getAddedComponents(Behavior)) do
		local scriptRunner = entity:getComponent(ScriptRunner);
		assert(scriptRunner);
		local script = behavior:getScript();
		assert(script:isInstanceOf(Script));
		scriptRunner:addScript(script);
		if not self._activeEntities[entity] then
			self._activeEntities[entity] = { scriptRunner = scriptRunner, behaviors = {} };
		end
		self._activeEntities[entity].behaviors[behavior] = script;
	end

	for behavior, entity in pairs(self._query:getRemovedComponents(Behavior)) do
		local activeEntity = self._activeEntities[entity];
		assert(activeEntity);
		assert(activeEntity.behaviors[behavior]);
		if entity:getComponent(ScriptRunner) == activeEntity.scriptRunner then
			activeEntity.scriptRunner:removeScript(activeEntity.behaviors[behavior]);
		end
		activeEntity.behaviors[behavior] = nil;
	end
end

return BehaviorSystem;
