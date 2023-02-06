local System = require("ecs/System");
local AllComponents = require("ecs/query/AllComponents");
local InputListener = require("mapscene/behavior/InputListener");
local ScriptRunner = require("mapscene/behavior/ScriptRunner");

local InputListenerSystem = Class("InputListenerSystem", System);

InputListenerSystem.init = function(self, ecs)
	InputListenerSystem.super.init(self, ecs);
	self._query = AllComponents:new({ InputListener, ScriptRunner });
	self:getECS():addQuery(self._query);
end

InputListenerSystem.duringScripts = function(self, dt)
	local entities = self._query:getEntities();
	for entity in pairs(entities) do
		local inputListener = entity:getComponent(InputListener);
		local scriptRunner = entity:getComponent(ScriptRunner);
		for _, commandEvent in inputListener:poll() do
			if inputListener:isDisabled() then
				return;
			end
			local inputContext = inputListener:getInputContextForCommand(commandEvent);
			if inputContext then
				inputContext:getContext():signal(commandEvent);
			else
				scriptRunner:signalAllScripts(commandEvent);
			end
		end
	end
end

return InputListenerSystem;
