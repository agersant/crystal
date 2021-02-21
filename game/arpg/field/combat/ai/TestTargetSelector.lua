local TargetSelector = require("arpg/field/combat/ai/TargetSelector");
local CombatData = require("arpg/field/combat/CombatData");
local Teams = require("arpg/field/combat/Teams");
local Entity = require("engine/ecs/Entity");
local MapScene = require("engine/mapscene/MapScene");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");

local tests = {};

tests[#tests + 1] = {name = "Get Nearest Enemy", gfx = "mock"};
tests[#tests].body = function()

	local scene = MapScene:new("test-data/empty_map.lua");

	local me = scene:spawn(Entity);
	local friend = scene:spawn(Entity);
	local enemyA = scene:spawn(Entity);
	local enemyB = scene:spawn(Entity);
	for _, entity in ipairs({me, friend, enemyA, enemyB}) do
		entity:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));
		entity:addComponent(CombatData:new());
		entity:addComponent(TargetSelector:new());
	end

	me:setTeam(Teams.party);
	friend:setTeam(Teams.party);
	enemyA:setTeam(Teams.wild);
	enemyB:setTeam(Teams.wild);

	me:setPosition(10, 10);
	friend:setPosition(8, 8);
	enemyA:setPosition(100, 100);
	enemyB:setPosition(15, 5);

	scene:update(0);
	local nearest = me:getNearestEnemy();
	assert(nearest == enemyB);
end

tests[#tests + 1] = {name = "Get Nearest Ally", gfx = "mock"};
tests[#tests].body = function()

	local scene = MapScene:new("test-data/empty_map.lua");

	local me = scene:spawn(Entity);
	local friendA = scene:spawn(Entity);
	local friendB = scene:spawn(Entity);
	local enemy = scene:spawn(Entity);
	for _, entity in ipairs({me, friendA, friendB, enemy}) do
		entity:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));
		entity:addComponent(CombatData:new());
		entity:addComponent(TargetSelector:new());
	end

	me:setTeam(Teams.wild);
	friendA:setTeam(Teams.wild);
	friendB:setTeam(Teams.wild);
	enemy:setTeam(Teams.party);

	me:setPosition(10, 10);
	friendA:setPosition(100, 100);
	friendB:setPosition(8, 8);
	enemy:setPosition(15, 5);

	scene:update(0);
	local nearest = me:getNearestAlly();
	assert(nearest == friendB);

	friendB:kill();
	local nearest = me:getNearestAlly();
	assert(nearest == friendA);
end

return tests;
