require("engine/utils/OOP");
local CombatData = require("arpg/combat/CombatData");
local HitEvent = require("arpg/combat/HitEvent");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/query/AllComponents");

local CombatSystem = Class("CombatSystem", System);

CombatSystem.init = function(self, ecs)
	CombatSystem.super.init(self, ecs);
	self._combatDataQuery = AllComponents:new({CombatData});
	self:getECS():addQuery(self._combatDataQuery);
end

CombatSystem.duringScripts = function(self, dt)
	local hitEvents = self:getECS():getEvents(HitEvent);
	for _, hitEvent in ipairs(hitEvents) do
		local attacker = hitEvent:getEntity();
		local victim = hitEvent:getTargetEntity();
		if self._combatDataQuery:contains(attacker) and self._combatDataQuery:contains(victim) then
			local damageIntent = hitEvent:getDamageIntent();
			attacker:inflictDamage(damageIntent, victim:getComponent(CombatData));
		end
	end
end

return CombatSystem;
