require("engine/utils/OOP");
local Stat = require("arpg/combat/Stat");
local Stats = require("arpg/combat/Stats");
local Damage = require("arpg/combat/damage/Damage");
local DamageEvent = require("arpg/combat/damage/DamageEvent");
local DamageIntent = require("arpg/combat/damage/DamageIntent");
local DamageScalingSources = require("arpg/combat/damage/DamageScalingSources");
local DamageTypes = require("arpg/combat/damage/DamageTypes");
local Elements = require("arpg/combat/damage/Elements");
local Teams = require("arpg/combat/Teams");
local Component = require("engine/ecs/Component");

local CombatData = Class("CombatData", Component);

-- IMPLEMENTATION

local computeScalingSourceAmount = function(self, target, scalingSource)
	if scalingSource == DamageScalingSources.ATTACKER_OFFENSE_PHYSICAL then
		return self._offenses[DamageTypes.PHYSICAL]:getValue();
	elseif scalingSource == DamageScalingSources.ATTACKER_OFFENSE_MAGIC then
		return self._offenses[DamageTypes.MAGIC]:getValue();
	elseif scalingSource == DamageScalingSources.ATTACKER_MAX_HEALTH then
		return self._health:getMaxValue();
	elseif scalingSource == DamageScalingSources.ATTACKER_CURRENT_HEALTH then
		return self._health:getValue();
	elseif scalingSource == DamageScalingSources.ATTACKER_MISSING_HEALTH then
		return self._health:getMaxValue() - self._health:getValue();
	elseif scalingSource == DamageScalingSources.VICTIM_MAX_HEALTH then
		return target._health:getMaxValue();
	elseif scalingSource == DamageScalingSources.VICTIM_CURRENT_HEALTH then
		return target._health:getValue();
	elseif scalingSource == DamageScalingSources.VICTIM_MISSING_HEALTH then
		return target._health:getMaxValue() - target._health:getValue();
	else
		error("Unexpected scaling source");
	end
end

local mitigateDamage = function(self, damage)
	local effectiveDamage = Damage:new();
	for _, damageType in pairs(DamageTypes) do
		for _, element in pairs(Elements) do
			local rawAmount = damage:getAmount(damageType, element);
			local mitigatedAmount = rawAmount;

			-- Apply defense stat
			local defense = self._defenses[damageType];
			assert(defense);
			local defenseValue = defense:getValue();
			local mitigationFactor = defenseValue / (defenseValue + 100);
			mitigatedAmount = mitigatedAmount * (1 - mitigationFactor);

			-- Apply elemental resistance
			local resistance = self._resistances[element];
			assert(resistance);
			mitigatedAmount = mitigatedAmount * (1 - resistance:getValue());

			effectiveDamage:addAmount(mitigatedAmount, damageType, element);
		end
	end
	return effectiveDamage;
end

-- PUBLIC API

CombatData.init = function(self)
	CombatData.super.init(self);
	self:setTeam(Teams.wild);

	self._stats = {};

	self._health = Stat:new(50, 0, nil);
	self._movementSpeed = Stat:new(100, 1, nil);
	self._stats[Stats.HEALTH] = self._health;
	self._stats[Stats.MOVEMENT_SPEED] = self._movementSpeed;

	self._offenses = {};
	self._defenses = {};
	for name, damageType in pairs(DamageTypes) do
		self._offenses[damageType] = Stat:new(10, 0, nil);
		self._defenses[damageType] = Stat:new(10, 0, nil);
		self._stats[Stats["OFFENSE_" .. name]] = self._offenses[damageType];
		self._stats[Stats["DEFENSE_" .. name]] = self._defenses[damageType];
	end

	self._affinities = {};
	self._resistances = {};
	for name, element in pairs(Elements) do
		self._affinities[element] = Stat:new(0, nil, nil);
		self._resistances[element] = Stat:new(0, nil, nil);
		self._stats[Stats["AFFINITY_" .. name]] = self._affinities[element];
		self._stats[Stats["RESISTANCE_" .. name]] = self._resistances[element];
	end
end

CombatData.setTeam = function(self, team)
	assert(Teams:isValid(team));
	self._team = team;
end

CombatData.getTeam = function(self)
	return self._team;
end

CombatData.computeDamage = function(self, intent, target)
	local damage = Damage:new();
	for component in pairs(intent:getComponents()) do
		local damageType = component:getDamageType();
		local element = component:getElement();
		local scalingRatio = component:getScalingRatio();
		local amount = component:getFlatAmount();

		-- Apply scaling
		if scalingRatio ~= 0 then
			local scalingSource = component:getScalingSource();
			local scalingSourceAmount = computeScalingSourceAmount(self, target, scalingSource);
			amount = amount + scalingRatio * scalingSourceAmount;
		end

		-- Apply affinity
		local affinity = self._affinities[element];
		assert(affinity);
		amount = amount * (1 + affinity:getValue());
		damage:addAmount(amount, damageType, element);
	end
	return damage;
end

CombatData.inflictDamage = function(self, intent, target)
	assert(intent);
	assert(target);
	assert(target:isInstanceOf(CombatData));
	assert(intent:isInstanceOf(DamageIntent));
	local damage = self:computeDamage(intent, target);
	target:receiveDamage(damage);
end

CombatData.receiveDamage = function(self, damage)
	if self:isDead() then
		return;
	end
	local effectiveDamage = mitigateDamage(self, damage);
	self._health:substract(effectiveDamage:getTotal());
	self:getEntity():createEvent(DamageEvent, effectiveDamage);
	return effectiveDamage;
end

CombatData.getCurrentHealth = function(self)
	return self._health:getValue();
end

CombatData.getMovementSpeed = function(self)
	return self._movementSpeed:getValue();
end

CombatData.kill = function(self)
	self._health:setValue(0);
end

CombatData.isDead = function(self)
	return self._health:getValue() == 0;
end

return CombatData;
