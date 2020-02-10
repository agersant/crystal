require("engine/utils/OOP");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/query/AllComponents");
local Controller = require("engine/scene/behavior/Controller");
local ScriptRunner = require("engine/scene/behavior/ScriptRunner");

local ControllerSystem = Class("ControllerSystem", System);

ControllerSystem.init = function(self, ecs)
	ControllerSystem.super.init(self, ecs);
	self._query = AllComponents:new({Controller, ScriptRunner});
	self:getECS():addQuery(self._query);
end

ControllerSystem.update = function(self, dt)
	for entity in pairs(self._query:getAddedEntities()) do
		local controller = entity:getComponent(Controller);
		local scriptRunner = entity:getComponent(ScriptRunner);
		scriptRunner:addScript(controller:getScript());
	end

	for entity in pairs(self._query:getRemovedEntities()) do
		local controller = entity:getComponent(Controller);
		local scriptRunner = entity:getComponent(ScriptRunner);
		scriptRunner:removeScript(controller:getScript());
	end
end

return ControllerSystem;
