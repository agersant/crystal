local DamageScalingSources = require("arpg/combat/damage/DamageScalingSources");
local DamageTypes = require("arpg/combat/damage/DamageTypes");
local DamageUnit = require("arpg/combat/damage/DamageUnit");
local DamageIntent = require("arpg/combat/damage/DamageIntent");
local Elements = require("arpg/combat/damage/Elements");
local CombatData = require("arpg/combat/CombatData");
local Stats = require("arpg/combat/Stats");
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
	intent:setDamageUnits({DamageUnit:new(10)});

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
	unit:setScalingAmount(2, DamageScalingSources.ATTACKER_OFFENSE_PHYSICAL);
	intent:setDamageUnits({unit});

	attacker:inflictDamage(intent, victim:getComponent(CombatData));
	assert(victim:getCurrentHealth() == 100);

	attacker:getStat(Stats.OFFENSE_PHYSICAL):setValue(3);
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
	victim:getStat(Stats.DEFENSE_PHYSICAL):setValue(100);

	intent:setDamageUnits({DamageUnit:new(100)});
	attacker:inflictDamage(intent, victim:getComponent(CombatData));
	assert(victim:getCurrentHealth() == 50);

	intent:setDamageUnits({DamageUnit:new(50)});
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
	intent:setDamageUnits({DamageUnit:new(10, DamageTypes.MAGIC, Elements.FIRE)});

	attacker:getStat(Stats.AFFINITY_FIRE):setValue(0.5);
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
	intent:setDamageUnits({DamageUnit:new(10, DamageTypes.MAGIC, Elements.FIRE)});

	victim:getStat(Stats.RESISTANCE_FIRE):setValue(0.5);
	attacker:inflictDamage(intent, victim:getComponent(CombatData));
	assert(victim:getCurrentHealth() == 95);
end

return tests;
