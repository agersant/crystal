local TargetSelector = require("arpg/combat/ai/TargetSelector");
local CombatLogic = require("arpg/combat/CombatLogic");
local Teams = require("arpg/combat/Teams");
local Entity = require("engine/ecs/Entity");
local MapScene = require("engine/scene/MapScene");
local ScriptRunner = require("engine/scene/behavior/ScriptRunner");
local PhysicsBody = require("engine/scene/physics/PhysicsBody");

local tests = {};

tests[#tests + 1] = {name = "Get Nearest Enemy"};
tests[#tests].body = function()

	local scene = MapScene:new("assets/map/test/empty.lua");

	local me = scene:spawn(Entity);
	local friend = scene:spawn(Entity);
	local enemyA = scene:spawn(Entity);
	local enemyB = scene:spawn(Entity);
	local targets = {me, friend, enemyA, enemyB};
	for _, entity in ipairs(targets) do
		entity:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));
		entity:addComponent(CombatLogic:new());
	end

	me:setTeam(Teams.party);
	friend:setTeam(Teams.party);
	enemyA:setTeam(Teams.wild);
	enemyB:setTeam(Teams.wild);

	me:setPosition(10, 10);
	friend:setPosition(8, 8);
	enemyA:setPosition(100, 100);
	enemyB:setPosition(15, 5);

	local selector = TargetSelector:new(targets);
	local nearest = selector:getNearestEnemy(me);
	assert(nearest == enemyB);
end

tests[#tests + 1] = {name = "Get Nearest Ally"};
tests[#tests].body = function()

	local scene = MapScene:new("assets/map/test/empty.lua");

	local me = scene:spawn(Entity);
	local friendA = scene:spawn(Entity);
	local friendB = scene:spawn(Entity);
	local enemy = scene:spawn(Entity);
	local targets = {me, friendA, friendB, enemy};
	for _, entity in ipairs(targets) do
		entity:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));
		entity:addComponent(CombatLogic:new());
	end

	me:setTeam(Teams.wild);
	friendA:setTeam(Teams.wild);
	friendB:setTeam(Teams.wild);
	enemy:setTeam(Teams.party);

	me:setPosition(10, 10);
	friendA:setPosition(100, 100);
	friendB:setPosition(8, 8);
	enemy:setPosition(15, 5);

	local selector = TargetSelector:new(targets);
	local nearest = selector:getNearestAlly(me);
	assert(nearest == friendB);

	friendB:addComponent(ScriptRunner:new()); -- TODO shouldnt be needed for this test
	friendB:kill();
	local nearest = selector:getNearestAlly(me);
	assert(nearest == friendA);
end

return tests;
