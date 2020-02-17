require("engine/utils/OOP");
local Component = require("engine/ecs/Component");
local Actor = require("engine/mapscene/behavior/Actor");
local InputListener = require("engine/mapscene/behavior/InputListener");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");
local Collision = require("engine/mapscene/physics/Collision");
local Script = require("engine/script/Script");

local InteractionControls = Class("InteractionControls", Component);

local script = function(self)
	while true do
		local inputListener = self:getComponent(InputListener);
		assert(inputListener);
		local inputDevice = inputListener:getInputDevice();
		assert(inputDevice);
		if inputDevice:isCommandActive("interact") then
			self:waitFor("-interact");
		end
		self:waitFor("+interact");

		local actor = self:getComponent(Actor);
		if not actor or actor:isIdle() then
			local collision = self:getComponent(Collision);
			assert(collision);
			for entity in pairs(collision:getContactEntities()) do
				local scriptRunner = entity:getComponent(ScriptRunner);
				if scriptRunner then
					scriptRunner:signalAllScripts("interact", self:getEntity());
				end
			end
		end
	end
end

InteractionControls.init = function(self)
	InteractionControls.super.init(self);
	self._script = Script:new(script);
end

InteractionControls.getScript = function(self)
	return self._script;
end

return InteractionControls;
