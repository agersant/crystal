local DamageScalingSource = require("arpg/field/combat/damage/DamageScalingSource");
local DamageTypes = require("arpg/field/combat/damage/DamageTypes");
local DamageUnit = require("arpg/field/combat/damage/DamageUnit");
local DamageIntent = require("arpg/field/combat/damage/DamageIntent");
local Elements = require("arpg/field/combat/damage/Elements");
local CombatData = require("arpg/field/combat/CombatData");
local ScalingSources = require("arpg/field/combat/stats/ScalingSources");
local StatModifier = require("arpg/field/combat/stats/StatModifier");
local Stats = require("arpg/field/combat/stats/Stats");
local Entity = require("engine/ecs/Entity");
local ECS = require("engine/ecs/ECS");

local tests = {};

tests[#tests + 1] = {name = "Kill"};
tests[#tests].body = function()
	local ecs = ECS:new();
	local entity = ecs:spawn(Entity);
	entity:addComponent(CombatData:new());
	assert(not entity:isDead());
	entity:kill();
	assert(entity:isDead());
end

tests[#tests + 1] = {name = "Inflict flat damage"};
tests[#tests].body = function()
	local ecs = ECS:new();
	local attacker = ecs:spawn(Entity);
	local victim = ecs:spawn(Entity);
	attacker:addComponent(CombatData:new());
	victim:addComponent(CombatData:new());
	ecs:update(0);

	local intent = DamageIntent:new();
	intent:setDamagePayload({DamageUnit:new(10)});

	attacker:inflictDamage(intent, victim:getComponent(CombatData));
	assert(victim:getCurrentHealth() == 90);
end

tests[#tests + 1] = {name = "Inflict scaling physical damage"};
tests[#tests].body = function()
	local ecs = ECS:new();
	local attacker = ecs:spawn(Entity);
	local victim = ecs:spawn(Entity);
	attacker:addComponent(CombatData:new());
	victim:addComponent(CombatData:new());
	ecs:update(0);

	local intent = DamageIntent:new();
	local unit = DamageUnit:new();
	unit:setScalingAmount(2, DamageScalingSource:new(ScalingSources.OFFENSE_PHYSICAL));
	intent:setDamagePayload({unit});

	attacker:inflictDamage(intent, victim:getComponent(CombatData));
	assert(victim:getCurrentHealth() == 100);

	attacker:getStat(Stats.OFFENSE_PHYSICAL):setBaseValue(3);
	attacker:inflictDamage(intent, victim:getComponent(CombatData));
	assert(victim:getCurrentHealth() == 94);
end

tests[#tests + 1] = {name = "Mitigate physical damage"};
tests[#tests].body = function()
	local ecs = ECS:new();
	local attacker = ecs:spawn(Entity);
	local victim = ecs:spawn(Entity);
	attacker:addComponent(CombatData:new());
	victim:addComponent(CombatData:new());
	ecs:update(0);

	local intent = DamageIntent:new();
	victim:getStat(Stats.DEFENSE_PHYSICAL):setBaseValue(100);

	intent:setDamagePayload({DamageUnit:new(100)});
	attacker:inflictDamage(intent, victim:getComponent(CombatData));
	assert(victim:getCurrentHealth() == 50);

	intent:setDamagePayload({DamageUnit:new(50)});
	attacker:inflictDamage(intent, victim:getComponent(CombatData));
	assert(victim:getCurrentHealth() == 25);
end

tests[#tests + 1] = {name = "Elemental affinity multiplies damage"};
tests[#tests].body = function()
	local ecs = ECS:new();
	local attacker = ecs:spawn(Entity);
	local victim = ecs:spawn(Entity);
	attacker:addComponent(CombatData:new());
	victim:addComponent(CombatData:new());
	ecs:update(0);

	local intent = DamageIntent:new();
	intent:setDamagePayload({DamageUnit:new(10, DamageTypes.MAGIC, Elements.FIRE)});

	attacker:getStat(Stats.AFFINITY_FIRE):setBaseValue(0.5);
	attacker:inflictDamage(intent, victim:getComponent(CombatData));
	assert(victim:getCurrentHealth() == 85);
end

tests[#tests + 1] = {name = "Elemental resistance multiplies damage"};
tests[#tests].body = function()
	local ecs = ECS:new();
	local attacker = ecs:spawn(Entity);
	local victim = ecs:spawn(Entity);
	attacker:addComponent(CombatData:new());
	victim:addComponent(CombatData:new());
	ecs:update(0);

	local intent = DamageIntent:new();
	intent:setDamagePayload({DamageUnit:new(10, DamageTypes.MAGIC, Elements.FIRE)});

	victim:getStat(Stats.RESISTANCE_FIRE):setBaseValue(0.5);
	attacker:inflictDamage(intent, victim:getComponent(CombatData));
	assert(victim:getCurrentHealth() == 95);
end

tests[#tests + 1] = {name = "Flat stat modifiers"};
tests[#tests].body = function()
	local ecs = ECS:new();
	local entity = ecs:spawn(Entity);
	entity:addComponent(CombatData:new());
	ecs:update(0);

	entity:addStatModifier(StatModifier:new(Stats.OFFENSE_MAGIC, 20));
	local offenseMagic = entity:getStat(Stats.OFFENSE_MAGIC);
	assert(offenseMagic:getBaseValue() == 0);
	assert(entity:evaluateStat(Stats.OFFENSE_MAGIC) == 20);
end

tests[#tests + 1] = {name = "Flat + same-stat percentage modifier"};
tests[#tests].body = function()
	local ecs = ECS:new();
	local entity = ecs:spawn(Entity);
	entity:addComponent(CombatData:new());
	ecs:update(0);

	local modifier = StatModifier:new(Stats.OFFENSE_MAGIC, 20);
	modifier:setScalingAmount(0.10, ScalingSources.OFFENSE_MAGIC);
	entity:addStatModifier(modifier);
	assert(entity:evaluateStat(Stats.OFFENSE_MAGIC) == 22);
end

tests[#tests + 1] = {name = "Convert 10% of offense into defense and vice versa"};
tests[#tests].body = function()
	local ecs = ECS:new();
	local entity = ecs:spawn(Entity);
	entity:addComponent(CombatData:new());
	ecs:update(0);

	local offenseModifier = StatModifier:new(Stats.OFFENSE_PHYSICAL, 0);
	offenseModifier:setScalingAmount(0.10, ScalingSources.DEFENSE_PHYSICAL);
	entity:addStatModifier(offenseModifier);

	local defenseModifier = StatModifier:new(Stats.DEFENSE_PHYSICAL, 0);
	defenseModifier:setScalingAmount(0.10, ScalingSources.OFFENSE_PHYSICAL);
	entity:addStatModifier(defenseModifier);

	entity:getStat(Stats.OFFENSE_PHYSICAL):setBaseValue(50);
	entity:getStat(Stats.DEFENSE_PHYSICAL):setBaseValue(100);

	assert(entity:evaluateStat(Stats.OFFENSE_PHYSICAL) == 60);
	assert(entity:evaluateStat(Stats.DEFENSE_PHYSICAL) == 105);
end

tests[#tests + 1] = {name = "Swap offense and defense"};
tests[#tests].body = function()
	local ecs = ECS:new();
	local entity = ecs:spawn(Entity);
	entity:addComponent(CombatData:new());
	ecs:update(0);

	local offenseNullify = StatModifier:new(Stats.OFFENSE_PHYSICAL, 0);
	offenseNullify:setScalingAmount(-1, ScalingSources.OFFENSE_PHYSICAL);
	local offenseSwap = StatModifier:new(Stats.OFFENSE_PHYSICAL, 0);
	offenseSwap:setScalingAmount(1, ScalingSources.DEFENSE_PHYSICAL);
	entity:addStatModifier(offenseNullify);
	entity:addStatModifier(offenseSwap);

	local defenseNullify = StatModifier:new(Stats.DEFENSE_PHYSICAL, 0);
	defenseNullify:setScalingAmount(-1, ScalingSources.DEFENSE_PHYSICAL);
	local defenseSwap = StatModifier:new(Stats.DEFENSE_PHYSICAL, 0);
	defenseSwap:setScalingAmount(1, ScalingSources.OFFENSE_PHYSICAL);
	entity:addStatModifier(defenseNullify);
	entity:addStatModifier(defenseSwap);

	entity:getStat(Stats.OFFENSE_PHYSICAL):setBaseValue(50);
	entity:getStat(Stats.DEFENSE_PHYSICAL):setBaseValue(100);

	assert(entity:evaluateStat(Stats.OFFENSE_PHYSICAL) == 100);
	assert(entity:evaluateStat(Stats.DEFENSE_PHYSICAL) == 50);
end

tests[#tests + 1] = {name = "Three way +10% stat modifiers"};
tests[#tests].body = function()
	local ecs = ECS:new();
	local entity = ecs:spawn(Entity);
	entity:addComponent(CombatData:new());
	ecs:update(0);

	local offenseFromDefense = StatModifier:new(Stats.OFFENSE_PHYSICAL, 0);
	offenseFromDefense:setScalingAmount(.1, ScalingSources.DEFENSE_PHYSICAL);
	entity:addStatModifier(offenseFromDefense);

	local defenseFromHealth = StatModifier:new(Stats.DEFENSE_PHYSICAL, 0);
	defenseFromHealth:setScalingAmount(.1, ScalingSources.HEALTH);
	entity:addStatModifier(defenseFromHealth);

	local healthFromOffense = StatModifier:new(Stats.HEALTH, 0);
	healthFromOffense:setScalingAmount(.1, ScalingSources.OFFENSE_PHYSICAL);
	entity:addStatModifier(healthFromOffense);

	entity:getStat(Stats.OFFENSE_PHYSICAL):setBaseValue(100);
	entity:getStat(Stats.DEFENSE_PHYSICAL):setBaseValue(100);
	entity:getStat(Stats.HEALTH):setBaseValue(100);
	assert(entity:evaluateStat(Stats.OFFENSE_PHYSICAL) == 111);
	assert(entity:evaluateStat(Stats.DEFENSE_PHYSICAL) == 111);
	assert(entity:evaluateStat(Stats.HEALTH) == 111);

	entity:getStat(Stats.OFFENSE_PHYSICAL):setBaseValue(50);
	entity:getStat(Stats.DEFENSE_PHYSICAL):setBaseValue(100);
	entity:getStat(Stats.HEALTH):setBaseValue(200);
	assert(entity:evaluateStat(Stats.OFFENSE_PHYSICAL) == 62);
	assert(entity:evaluateStat(Stats.DEFENSE_PHYSICAL) == 120.5);
	assert(entity:evaluateStat(Stats.HEALTH) == 206);
end

return tests;
