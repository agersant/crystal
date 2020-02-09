require("engine/utils/OOP");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/Query/AllComponents");
local Controller = require("engine/scene/behavior/Controller");
local ScriptRunner = require("engine/scene/behavior/ScriptRunner");

local ControllerSystem = Class("ControllerSystem", System);

ControllerSystem.init = function(self, ecs)
	ControllerSystem.super.init(self, ecs);
	self._query = AllComponents:new({Controller, ScriptRunner});
	self:getECS():addQuery(self._query);
end

ControllerSystem.update = function(self, dt)
	for _, entity in self._query:getAddedEntities() do
		entity:addScript(entity:getControllerScript());
	end

	for _, entity in self._query:getRemovedEntities() do
		entity:removeScript(entity:getControllerScript());
	end
end

return ControllerSystem;
