local InputListener = require("mapscene/behavior/InputListener");
local ScriptRunner = require("mapscene/behavior/ScriptRunner");

local InputListenerSystem = Class("InputListenerSystem", crystal.System);

InputListenerSystem.init = function(self)
	self._query = self:add_query({ InputListener, ScriptRunner });
end

InputListenerSystem.duringScripts = function(self, dt)
	local entities = self._query:entities();
	for entity in pairs(entities) do
		local inputListener = entity:component(InputListener);
		local scriptRunner = entity:component(ScriptRunner);
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
