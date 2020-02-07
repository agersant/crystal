local Damage = require("engine/combat/Damage");
local CombatData = require("engine/scene/component/CombatData");
local Entity = require("engine/ecs/Entity");
local MapScene = require("engine/scene/MapScene");
local ScriptRunner = require("engine/scene/behavior/ScriptRunner");

local tests = {};

tests[#tests + 1] = {name = "Kill"};
tests[#tests].body = function()
	local scene = MapScene:new("assets/map/test/empty.lua");
	local entity = scene:spawn(Entity);
	entity:addComponent(ScriptRunner:new(scene)); -- TODO shouldnt be needed for this test
	local combatData = CombatData:new(entity);
	assert(not combatData:isDead());
	combatData:kill();
	assert(combatData:isDead());
end

tests[#tests + 1] = {name = "Inflicting damage reduces health"};
tests[#tests].body = function()
	local scene = MapScene:new("assets/map/test/empty.lua");

	local attacker = scene:spawn(Entity);
	local victim = scene:spawn(Entity);
	attacker:addComponent(ScriptRunner:new(scene)); -- TODO shouldnt be needed for this test
	victim:addComponent(ScriptRunner:new(scene)); -- TODO shouldnt be needed for this test
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
