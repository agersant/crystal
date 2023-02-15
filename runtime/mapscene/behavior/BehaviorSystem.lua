local AllComponents = require("ecs/query/AllComponents");
local Behavior = require("mapscene/behavior/Behavior");
local ScriptRunner = require("mapscene/behavior/ScriptRunner");
local Script = require("script/Script");

local BehaviorSystem = Class("BehaviorSystem", crystal.System);

BehaviorSystem.init = function(self, ecs)
	BehaviorSystem.super.init(self, ecs);
	self._activeEntities = {};
	self._query = AllComponents:new({ Behavior, ScriptRunner });
	self._ecs:add_query(self._query);
end

BehaviorSystem.beforeScripts = function(self, dt)
	for behavior, entity in pairs(self._query:getAddedComponents(Behavior)) do
		local scriptRunner = entity:component(ScriptRunner);
		assert(scriptRunner);
		local script = behavior:getScript();
		assert(script:is_instance_of(Script));
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
		if entity:component(ScriptRunner) == activeEntity.scriptRunner then
			activeEntity.scriptRunner:removeScript(activeEntity.behaviors[behavior]);
		end
		activeEntity.behaviors[behavior] = nil;
	end
end

return BehaviorSystem;
