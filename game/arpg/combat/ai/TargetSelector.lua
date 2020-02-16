require("engine/utils/OOP");
local CombatData = require("arpg/combat/CombatData");
local Teams = require("arpg/combat/Teams");
local Component = require("engine/ecs/Component");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");

local TargetSelector = Class("TargetSelector", Component);

TargetSelector.init = function(self)
	TargetSelector.super.init(self);
end

local getAllPossibleTargets = function(self)
	local ecs = self:getEntity():getECS();
	return ecs:getAllEntitiesWith(CombatData);
end

local passesFilters = function(self, filters, target)
	for _, filter in ipairs(filters) do
		if not filter(self, target) then
			return false;
		end
	end
	return true;
end

local getAll = function(self, filters)
	local out = {};
	for target in pairs(getAllPossibleTargets(self)) do
		if passesFilters(self, filters, target) then
			table.insert(out, target);
		end
	end
	return out;
end

local getFittest = function(self, filters, rank)
	local bestScore = nil;
	local bestTarget = nil;
	for target in pairs(getAllPossibleTargets(self)) do
		if passesFilters(self, filters, target) then
			local score = rank(self, target);
			if not bestScore or score > bestScore then
				bestScore = score;
				bestTarget = target;
			end
		end
	end
	return bestTarget;
end

local isAllyOf = function(self, target)
	return Teams:areAllies(self:getEntity():getTeam(), target:getTeam());
end

local isEnemyOf = function(self, target)
	return Teams:areEnemies(self:getEntity():getTeam(), target:getTeam());
end

local isNotSelf = function(self, target)
	return self:getEntity() ~= target;
end

local rankByDistance = function(self, target)
	local physicsBody = self:getEntity():getComponent(PhysicsBody);
	if not physicsBody then
		return -math.huge;
	end
	return -physicsBody:distance2ToEntity(target);
end

local isAlive = function(self, target)
	local combatData = target:getComponent(CombatData);
	if not combatData then
		return false;
	end
	return not combatData:isDead();
end

TargetSelector.getAllies = function(self)
	return getAll(self, {isAlive, isAllyOf, isNotSelf});
end

TargetSelector.getEnemies = function(self)
	return getAll(self, {isAlive, isEnemyOf, isNotSelf});
end

TargetSelector.getNearestEnemy = function(self)
	return getFittest(self, {isAlive, isEnemyOf, isNotSelf}, rankByDistance);
end

TargetSelector.getNearestAlly = function(self)
	return getFittest(self, {isAlive, isAllyOf, isNotSelf}, rankByDistance);
end

return TargetSelector;
