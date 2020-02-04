local Party = require("engine/persistence/Party");
local Damage = require("engine/combat/Damage");
local CombatData = require("engine/scene/component/CombatData");
local Entity = require("engine/scene/entity/Entity");
local MapScene = require("engine/scene/MapScene");

local tests = {};

tests[#tests + 1] = {name = "Kill"};
tests[#tests].body = function()
	local party = Party:new();
	local scene = MapScene:new("assets/map/test/empty.lua", party);
	local entity = Entity:new(scene);
	local combatData = CombatData:new(entity);
	assert(not combatData:isDead());
	combatData:kill();
	assert(combatData:isDead());
end

tests[#tests + 1] = {name = "Inflicting damage reduces health"};
tests[#tests].body = function()
	local party = Party:new();
	local scene = MapScene:new("assets/map/test/empty.lua", party);

	local attacker = Entity:new(scene);
	local victim = Entity:new(scene);
	attacker:addCombatData();
	victim:addCombatData();

	local attackerHealth = attacker:getHealth();
	local victimHealth = victim:getHealth();

	local damage = Damage:new(10, attacker);
	attacker:inflictDamageTo(victim, damage);
	assert(attacker:getHealth() == attackerHealth);
	assert(victim:getHealth() < victimHealth);
end

return tests;
