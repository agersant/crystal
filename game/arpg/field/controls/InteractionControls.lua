require("engine/utils/OOP");
local Actor = require("engine/mapscene/behavior/Actor");
local Behavior = require("engine/mapscene/behavior/Behavior");
local InputListener = require("engine/mapscene/behavior/InputListener");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");
local Collision = require("engine/mapscene/physics/Collision");

local InteractionControls = Class("InteractionControls", Behavior);

local scriptFunction = function(self)
	while true do
		local inputListener = self:getComponent(InputListener);
		if not inputListener then
			self:waitFrame();
		end
		local inputDevice = inputListener:getInputDevice();
		assert(inputDevice);

		if inputDevice:isCommandActive("interact") then
			self:waitFor("-interact");
		end
		self:waitFor("+interact");

		local actor = self:getComponent(Actor);
		if not actor or actor:isIdle() then
			local collision = self:getComponent(Collision);
			if collision then
				for entity in pairs(collision:getContactEntities()) do
					local scriptRunner = entity:getComponent(ScriptRunner);
					if scriptRunner then
						scriptRunner:signalAllScripts("interact", self:getEntity());
					end
				end
			end
		end
	end
end

InteractionControls.init = function(self)
	InteractionControls.super.init(self, scriptFunction)
end

return InteractionControls;
