local TargetSelector = require("engine/ai/tactics/TargetSelector");
local Teams = require("engine/combat/Teams");
local Party = require("arpg/party/Party");
local MapScene = require("engine/scene/MapScene");
local Entity = require("engine/scene/entity/Entity");

local tests = {};

tests[#tests + 1] = {name = "Get Nearest Enemy"};
tests[#tests].body = function()

	local party = Party:new();
	local scene = MapScene:new("assets/map/test/empty.lua", party);

	local me = Entity:new(scene);
	local friend = Entity:new(scene);
	local enemyA = Entity:new(scene);
	local enemyB = Entity:new(scene);
	local targets = {me, friend, enemyA, enemyB};
	for _, entity in ipairs(targets) do
		entity:addPhysicsBody();
		entity:addCombatData();
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

	local party = Party:new();
	local scene = MapScene:new("assets/map/test/empty.lua", party);

	local me = Entity:new(scene);
	local friendA = Entity:new(scene);
	local friendB = Entity:new(scene);
	local enemy = Entity:new(scene);
	local targets = {me, friendA, friendB, enemy};
	for _, entity in ipairs(targets) do
		entity:addPhysicsBody();
		entity:addCombatData();
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

	friendB:kill();
	local nearest = selector:getNearestAlly(me);
	assert(nearest == friendA);
end

return tests;
