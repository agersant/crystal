require("engine/utils/OOP");
local Stat = require("arpg/field/combat/stats/Stat");
local Stats = require("arpg/field/combat/stats/Stats");
local Damage = require("arpg/field/combat/damage/Damage");
local DamageEvent = require("arpg/field/combat/damage/DamageEvent");
local DeathEvent = require("arpg/field/combat/damage/DeathEvent");
local DamageIntent = require("arpg/field/combat/damage/DamageIntent");
local DamageTypes = require("arpg/field/combat/damage/DamageTypes");
local Elements = require("arpg/field/combat/damage/Elements");
local ScalingSources = require("arpg/field/combat/stats/ScalingSources");
local Teams = require("arpg/field/combat/Teams");
local Component = require("engine/ecs/Component");
local TableUtils = require("engine/utils/TableUtils");

local CombatData = Class("CombatData", Component);

local computeScalingSourceAmount, computeScalingSourceAmountInternal;

local evaluateStatInternal = function(self, statObject, guards)
	assert(statObject);
	assert(statObject:isInstanceOf(Stat));

	local stat = self._statsReverseLookups[statObject];
	assert(stat);

	local guards = guards or {};
	local newGuards = TableUtils.shallowCopy(guards);
	newGuards[stat] = true;

	for modifier in pairs(self._statModifiers[stat]) do
		local scalingRatio = modifier:getScalingRatio();
		if scalingRatio ~= 0 then
			local scalingSource = modifier:getScalingSource();
			newGuards[scalingSource] = true;
		end
	end

	local value = statObject:getBaseValue();
	for modifier in pairs(self._statModifiers[stat]) do
		value = value + modifier:getFlatAmount();
		local scalingSource = modifier:getScalingSource();
		if not guards[scalingSource] then
			local scalingRatio = modifier:getScalingRatio();
			if scalingRatio ~= 0 then
				local scalingSourceValue = computeScalingSourceAmountInternal(self, scalingSource, newGuards);
				value = value + scalingRatio * scalingSourceValue;
			end
		end
	end

	return value;
end

computeScalingSourceAmountInternal = function(self, scalingSource, guards)
	if self._stats[scalingSource] then
		return evaluateStatInternal(self, self:getStat(scalingSource), guards);
	elseif scalingSource == ScalingSources.MISSING_HEALTH then
		local max = evaluateStatInternal(self, self:getStat(Stats.MAX_HEALTH), guards);
		local current = evaluateStatInternal(self, self:getStat(Stats.HEALTH), guards);
		return max - current;
	else
		error("Unexpected scaling source");
	end
end

computeScalingSourceAmount = function(self, scalingSource)
	return computeScalingSourceAmountInternal(self, scalingSource, {});
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
			local defenseValue = evaluateStatInternal(self, defense);
			local mitigationFactor = defenseValue / (defenseValue + 100);
			mitigatedAmount = mitigatedAmount * (1 - mitigationFactor);

			-- Apply elemental resistance
			local resistance = self._resistances[element];
			assert(resistance);
			mitigatedAmount = mitigatedAmount * (1 - evaluateStatInternal(self, resistance));

			effectiveDamage:addAmount(mitigatedAmount, damageType, element);
		end
	end
	return effectiveDamage;
end

local computeDamage = function(self, intent, target)
	local damage = Damage:new();
	for unit in pairs(intent:getDamageUnits()) do
		local damageType = unit:getDamageType();
		local element = unit:getElement();
		local scalingRatio = unit:getScalingRatio();
		local amount = unit:getFlatAmount();

		-- Apply scaling
		if scalingRatio ~= 0 then
			local damageScalingSource = unit:getDamageScalingSource();
			local scalingSource = damageScalingSource:getScalingSource();
			local scalingSourceAmount;
			if damageScalingSource:isScalingOffTarget() then
				scalingSourceAmount = computeScalingSourceAmount(target, scalingSource);
			else
				scalingSourceAmount = computeScalingSourceAmount(self, scalingSource);
			end
			if scalingSourceAmount ~= 0 then
				amount = amount + scalingRatio * scalingSourceAmount;
			end
		end

		-- Apply affinity
		local affinity = self._affinities[element];
		assert(affinity);
		amount = amount * (1 + evaluateStatInternal(self, affinity));
		damage:addAmount(amount, damageType, element);
	end
	return damage;
end

local addStat = function(self, stat, statObject)
	assert(not self._stats[stat]);
	self._stats[stat] = statObject;
	self._statsReverseLookups[statObject] = stat;
	return statObject;
end

CombatData.init = function(self)
	CombatData.super.init(self);
	self:setTeam(Teams.wild);

	self._stats = {};
	self._statsReverseLookups = {};

	addStat(self, Stats.MOVEMENT_SPEED, Stat:new(100, 1, nil));
	addStat(self, Stats.HEALTH, Stat:new(100, 0, nil));
	addStat(self, Stats.MAX_HEALTH, Stat:new(100, 1, nil));

	self._offenses = {};
	self._defenses = {};
	for name, damageType in pairs(DamageTypes) do
		self._offenses[damageType] = addStat(self, Stats["OFFENSE_" .. name], Stat:new(0, 0, nil));
		self._defenses[damageType] = addStat(self, Stats["DEFENSE_" .. name], Stat:new(0, 0, nil));
	end

	self._affinities = {};
	self._resistances = {};
	for name, element in pairs(Elements) do
		self._affinities[element] = addStat(self, Stats["AFFINITY_" .. name], Stat:new(0, 0, nil));
		self._resistances[element] = addStat(self, Stats["RESISTANCE_" .. name], Stat:new(0, 0, nil));
	end

	self._buffs = {};
	self._onHitEffects = {};
	self._statModifiers = {};

	for stat, statObject in pairs(self._stats) do
		self._statModifiers[stat] = {};
	end
end

CombatData.setTeam = function(self, team)
	assert(Teams:isValid(team));
	self._team = team;
end

CombatData.getTeam = function(self)
	return self._team;
end

CombatData.inflictDamage = function(self, intent, target)
	assert(intent);
	assert(target);
	assert(target:isInstanceOf(CombatData));
	assert(intent:isInstanceOf(DamageIntent));
	local damage = computeDamage(self, intent, target);
	local onHitEffects = {};
	for _, onHitEffect in ipairs(intent:getOnHitEffects()) do
		table.insert(onHitEffects, onHitEffect);
	end
	for onHitEffect in pairs(self._onHitEffects) do
		table.insert(onHitEffects, onHitEffect);
	end
	target:receiveDamage(self, damage, onHitEffects);
end

CombatData.receiveDamage = function(self, attacker, damage, onHitEffects)
	assert(attacker);
	assert(damage);
	assert(onHitEffects);
	if self:isDead() then
		return;
	end
	local effectiveDamage = mitigateDamage(self, damage);
	local health = self:getStat(Stats.HEALTH);
	health:substract(effectiveDamage:getTotal());
	self:getEntity():createEvent(DamageEvent, attacker, effectiveDamage, onHitEffects);
	if self:isDead() then
		self:getEntity():createEvent(DeathEvent);
	end
	return effectiveDamage;
end

CombatData.addBuff = function(self, buff)
	self._buffs[buff] = true;
	buff:install(self);
end

CombatData.removeBuff = function(self, buff)
	assert(self._buffs[buff]);
	self._buffs[buff] = nil;
	buff:uninstall(self);
end

CombatData.addOnHitEffect = function(self, onHitEffect)
	self._onHitEffects[onHitEffect] = true;
end

CombatData.removeOnHitEffect = function(self, onHitEffect)
	assert(self._onHitEffects[onHitEffect]);
	self._onHitEffects[onHitEffect] = nil;
end

CombatData.addStatModifier = function(self, statModifier)
	self._statModifiers[statModifier:getStat()][statModifier] = true;
end

CombatData.removeStatModifier = function(self, statModifier)
	self._statModifiers[statModifier:getStat()][statModifier] = nil;
end

CombatData.getStat = function(self, stat)
	local outputStat = self._stats[stat];
	assert(outputStat)
	return outputStat;
end

CombatData.evaluateStat = function(self, stat)
	assert(stat);
	assert(type(stat) == "number");
	return evaluateStatInternal(self, self:getStat(stat), {});
end

CombatData.getCurrentHealth = function(self)
	return self:evaluateStat(Stats.HEALTH);
end

CombatData.getMovementSpeed = function(self)
	return self:evaluateStat(Stats.MOVEMENT_SPEED);
end

CombatData.kill = function(self)
	self:getStat(Stats.HEALTH):setBaseValue(0);
end

CombatData.isDead = function(self)
	return self:getCurrentHealth() <= 0;
end

return CombatData;
