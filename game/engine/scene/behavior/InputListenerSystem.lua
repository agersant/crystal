require("engine/utils/OOP");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/Query/AllComponents");
local InputListener = require("engine/scene/behavior/InputListener");
local ScriptRunner = require("engine/scene/behavior/ScriptRunner");

local InputListenerSystem = Class("InputListenerSystem", System);

InputListenerSystem.init = function(self, ecs)
	InputListenerSystem.super.init(self, ecs);
	self._query = AllComponents:new({InputListener, ScriptRunner});
	self:getECS():addQuery(self._query);
end

InputListenerSystem.update = function(self, dt)
	local entities = self:getECS():query(self._query);
	for entity in pairs(entities) do
		local inputListener = entity:getComponent(InputListener);
		local scriptRunner = entity:getComponent(ScriptRunner);
		for _, commandEvent in inputListener:poll() do
			if inputListener:isDisabled() then
				return;
			end
			scriptRunner:signalAllScripts(commandEvent);
		end
	end
end

return InputListenerSystem;
