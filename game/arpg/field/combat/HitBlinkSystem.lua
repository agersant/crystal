require("engine/utils/OOP");
local HitBlink = require("arpg/field/combat/HitBlink");
local CommonShader = require("arpg/graphics/CommonShader");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");
local AllComponents = require("engine/ecs/query/AllComponents");
local System = require("engine/ecs/System");

local HitBlinkSystem = Class("HitBlinkSystem", System);

HitBlinkSystem.init = function(self, ecs)
	HitBlinkSystem.super.init(self, ecs);
	self._query = AllComponents:new({CommonShader, HitBlink, ScriptRunner});
	self:getECS():addQuery(self._query);
end

HitBlinkSystem.beforeScripts = function(self)
	for hitBlink in pairs(self._query:getAddedComponents(HitBlink)) do
		local entity = hitBlink:getEntity();
		local scriptRunner = entity:getComponent(ScriptRunner);
		scriptRunner:addScript(hitBlink:getScript());
	end

	for hitBlink in pairs(self._query:getRemovedComponents(HitBlink)) do
		local entity = hitBlink:getEntity();
		local scriptRunner = entity:getComponent(ScriptRunner);
		scriptRunner:removeScript(hitBlink:getScript());
	end
end

return HitBlinkSystem;
