require("engine/utils/OOP");
local CombatData = require("engine/scene/component/CombatData");
local CombatLogic = require("engine/scene/component/CombatLogic");
local Alias = require("engine/utils/Alias");

local Entity = Class("Entity");

Entity.init = function(self, ecs)
	assert(ecs);
	self._ecs = ecs;
end

Entity.getECS = function(self)
	return self._ecs;
end

Entity.addComponent = function(self, component)
	assert(component);
	self._ecs:addComponent(self, component);
	Alias:add(self, component);
end

Entity.removeComponent = function(self, component)
	assert(component);
	self._ecs:removeComponent(self, component);
	Alias:remove(self, component);
end

Entity.getComponent = function(self, class)
	return self._ecs:getComponent(self, class);
end

Entity.getComponents = function(self, baseClass)
	return self._ecs:getComponents(self, baseClass);
end

Entity.despawn = function(self)
	self._ecs:despawn(self);
end

Entity.setIsValid = function(self, isValid)
	self._isValid = isValid;
end

Entity.isValid = function(self)
	return self._isValid;
end

-- PHYSICS BODY COMPONENT

Entity.getScreenPosition = function(self)
	local x, y = self:getPosition();
	local camera = self:getScene():getCamera();
	return camera:getRelativePosition(x, y);
end

-- LOCOMOTION COMPONENT

Entity.setMovementSpeed = function(self, speed)
	return self._movementStat:setValue(speed);
end

Entity.getMovementSpeed = function(self)
	return self._movementStat:getValue();
end

-- PARTY COMPONENT

Entity.addToParty = function(self)
	self._ecs:addEntityToParty(self);
end

Entity.removeFromParty = function(self)
	self._ecs:removeEntityFromParty(self);
end

-- COMBAT DATA COMPONENT

Entity.addCombatData = function(self)
	assert(not self._combatData);
	self._combatData = CombatData:new(self);
end

Entity.inflictDamageTo = function(self, target)
	assert(self._combatData);
	self._combatData:inflictDamageTo(target);
end

Entity.receiveDamage = function(self, damage)
	assert(self._combatData);
	self._combatData:receiveDamage(damage);
end

Entity.getHealth = function(self)
	assert(self._combatData);
	return self._combatData:getHealth();
end

Entity.kill = function(self)
	assert(self._combatData);
	self._combatData:kill();
end

Entity.setTeam = function(self, team)
	assert(self._combatData);
	self._combatData:setTeam(team);
end

Entity.getTeam = function(self)
	assert(self._combatData);
	return self._combatData:getTeam();
end

Entity.isDead = function(self)
	assert(self._combatData);
	return self._combatData:isDead();
end

-- COMBAT LOGIC COMPONENT

Entity.addCombatLogic = function(self)
	assert(not self._combatLogic);
	self._combatLogic = CombatLogic:new(self);
	self:addScript(self._combatLogic);
end

Entity.getScene = function(self)
	return self._ecs;
end

return Entity;
