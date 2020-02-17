require("engine/utils/OOP");
local InteractionControls = require("arpg/field/controls/InteractionControls");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/query/AllComponents");
local InputListener = require("engine/mapscene/behavior/InputListener");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");
local Collision = require("engine/mapscene/physics/Collision");

local InteractionControlsSystem = Class("InteractionControlsSystem", System);

InteractionControlsSystem.init = function(self, ecs)
	InteractionControlsSystem.super.init(self, ecs);
	self._query = AllComponents:new({InteractionControls, Collision, InputListener, ScriptRunner});
	self:getECS():addQuery(self._query);
end

InteractionControlsSystem.beforeScripts = function(self, dt)
	for entity in pairs(self._query:getAddedEntities()) do
		local interactionControls = entity:getComponent(InteractionControls);
		local scriptRunner = entity:getComponent(ScriptRunner);
		scriptRunner:addScript(interactionControls:getScript());
	end

	for entity in pairs(self._query:getRemovedEntities()) do
		local interactionControls = entity:getComponent(InteractionControls);
		local scriptRunner = entity:getComponent(ScriptRunner);
		if scriptRunner and interactionControls then
			scriptRunner:removeScript(interactionControls:getScript());
		end
	end
end

return InteractionControlsSystem;
