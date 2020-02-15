require("engine/utils/OOP");
local CombatData = require("arpg/combat/CombatData");
local DamageEvent = require("arpg/combat/damage/DamageEvent");
local HitEvent = require("arpg/combat/HitEvent");
local Teams = require("arpg/combat/Teams");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/query/AllComponents");
local Actor = require("engine/mapscene/behavior/Actor");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");
local Locomotion = require("engine/mapscene/physics/Locomotion");

local CombatSystem = Class("CombatSystem", System);

CombatSystem.init = function(self, ecs)
	CombatSystem.super.init(self, ecs);
	self._combatDataQuery = AllComponents:new({CombatData});
	self._scriptRunnerQuery = AllComponents:new({ScriptRunner});
	self._locomotionQuery = AllComponents:new({CombatData, Locomotion});
	self:getECS():addQuery(self._combatDataQuery);
	self:getECS():addQuery(self._scriptRunnerQuery);
	self:getECS():addQuery(self._locomotionQuery);
end

CombatSystem.beforeScripts = function(self, dt)
	local entities = self._locomotionQuery:getEntities();
	for entity in pairs(entities) do
		local actor = entity:getComponent(Actor);
		if not actor or actor:isIdle() then
			local locomotion = entity:getComponent(Locomotion);
			local combatData = entity:getComponent(CombatData);
			local speed = combatData:getMovementSpeed();
			locomotion:setSpeed(speed);
		end
	end
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
			victim:signalAllScripts("disrupted");
			victim:signalAllScripts("receivedDamage", damage);
		end
	end
end

return CombatSystem;
