local Damage = require("arpg/combat/Damage");
local CombatLogic = require("arpg/combat/CombatLogic");
local Entity = require("engine/ecs/Entity");
local MapScene = require("engine/mapscene/MapScene");

local tests = {};

tests[#tests + 1] = {name = "Kill"};
tests[#tests].body = function()
	local scene = MapScene:new("assets/map/test/empty.lua");
	local entity = scene:spawn(Entity);
	entity:addComponent(CombatLogic:new());
	assert(not entity:isDead());
	entity:kill();
	assert(entity:isDead());
end

tests[#tests + 1] = {name = "Inflicting damage reduces health"};
tests[#tests].body = function()
	local scene = MapScene:new("assets/map/test/empty.lua");

	local attacker = scene:spawn(Entity);
	local victim = scene:spawn(Entity);
	attacker:addComponent(CombatLogic:new());
	victim:addComponent(CombatLogic:new());

	local attackerHealth = attacker:getHealth();
	local victimHealth = victim:getHealth();

	local damage = Damage:new(10, attacker);
	attacker:inflictDamageTo(victim, damage);
	assert(attacker:getHealth() == attackerHealth);
	assert(victim:getHealth() < victimHealth);
end

return tests;
