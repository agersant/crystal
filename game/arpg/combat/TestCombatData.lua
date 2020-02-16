local DamageUnit = require("arpg/combat/damage/DamageUnit");
local DamageIntent = require("arpg/combat/damage/DamageIntent");
local CombatData = require("arpg/combat/CombatData");
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

tests[#tests + 1] = {name = "Inflicting damage reduces health"};
tests[#tests].body = function()
	local ecs = ECS:new();

	local attacker = ecs:spawn(Entity);
	local victim = ecs:spawn(Entity);
	attacker:addComponent(CombatData:new());
	victim:addComponent(CombatData:new());

	ecs:update(0);

	local attackerHealth = attacker:getCurrentHealth();
	local victimHealth = victim:getCurrentHealth();

	local intent = DamageIntent:new();
	intent:setDamageUnits({DamageUnit:new(10)});

	attacker:inflictDamage(intent, victim:getComponent(CombatData));
	assert(attacker:getCurrentHealth() == attackerHealth);
	assert(victim:getCurrentHealth() < victimHealth);
end

-- TODO test defensive stat
-- TODO test flat damage
-- TODO test scaling damage
-- TODO test affinities
-- TODO test resistances

return tests;
