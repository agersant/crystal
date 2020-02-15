require("engine/utils/OOP");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/query/AllComponents");
local Actor = require("engine/mapscene/behavior/Actor");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");

local ActorSystem = Class("ActorSystem", System);

ActorSystem.init = function(self, ecs)
	ActorSystem.super.init(self, ecs);
	self._withScriptRunner = AllComponents:new({Actor, ScriptRunner});
	self:getECS():addQuery(self._withScriptRunner);
end

ActorSystem.beforeScripts = function(self, dt)
	for entity in pairs(self._withScriptRunner:getAddedEntities()) do
		local actor = entity:getComponent(Actor);
		local scriptRunner = entity:getComponent(ScriptRunner);
		scriptRunner:addScript(actor:getScript());
	end

	for entity in pairs(self._withScriptRunner:getRemovedEntities()) do
		local actor = entity:getComponent(Actor);
		local scriptRunner = entity:getComponent(ScriptRunner);
		scriptRunner:removeScript(actor:getScript());
	end
end

return ActorSystem;
