require("engine/utils/OOP");
local CombatData = require("arpg/combat/CombatData");
local DamageEvent = require("arpg/combat/damage/DamageEvent");
local HitEvent = require("arpg/combat/HitEvent");
local Teams = require("arpg/combat/Teams");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/query/AllComponents");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");

local CombatSystem = Class("CombatSystem", System);

CombatSystem.init = function(self, ecs)
	CombatSystem.super.init(self, ecs);
	self._combatDataQuery = AllComponents:new({CombatData});
	self._scriptRunnerQuery = AllComponents:new({ScriptRunner});
	self:getECS():addQuery(self._combatDataQuery);
	self:getECS():addQuery(self._scriptRunnerQuery);
end

CombatSystem.duringScripts = function(self, dt)
	local hitEvents = self:getECS():getEvents(HitEvent);
	for _, hitEvent in ipairs(hitEvents) do
		local attacker = hitEvent:getEntity();
		local victim = hitEvent:getTargetEntity();
		if Teams:areEnemies(attacker:getTeam(), victim:getTeam()) then
			if self._combatDataQuery:contains(attacker) and self._combatDataQuery:contains(victim) then
				local damageIntent = hitEvent:getDamageIntent();
				attacker:inflictDamage(damageIntent, victim:getComponent(CombatData));
			end
		end
	end

	local damageEvents = self:getECS():getEvents(DamageEvent);
	for _, damageEvent in ipairs(damageEvents) do
		local victim = damageEvent:getEntity();
		if self._scriptRunnerQuery:contains(victim) then
			local damage = damageEvent:getDamage();
			assert(damage);
			victim:signalAllScripts("receivedDamage", damage);
		end
	end
end

return CombatSystem;
