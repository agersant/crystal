require("engine/utils/OOP");
local DebugFlags = require("engine/dev/DebugFlags");
local Colors = require("engine/resources/Colors");
local CollisionFilters = require("engine/scene/CollisionFilters");
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

Entity.activate = function(self)
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

-- HITBOX COMPONENT

Entity.addHitboxPhysics = function(self, shape)
	assert(self._body);
	if self._hitboxShape == shape then
		return;
	end
	self:removeHitboxPhysics();
	self._hitboxFixture = love.physics.newFixture(self._body, shape);
	self._hitboxFixture:setFilterData(CollisionFilters.HITBOX, CollisionFilters.WEAKBOX, 0);
	self._hitboxFixture:setSensor(true);
	self._hitboxShape = shape;
end

Entity.removeHitboxPhysics = function(self)
	if self._hitboxFixture then
		self._hitboxFixture:destroy();
	end
	self._hitboxFixture = nil;
	self._hitboxShape = nil;
end

-- WEAKBOX COMPONENT

Entity.addWeakboxPhysics = function(self, shape)
	assert(self._body);
	if self._weakboxShape == shape then
		return;
	end
	self:removeWeakboxPhysics();
	self._weakboxFixture = love.physics.newFixture(self._body, shape);
	self._weakboxFixture:setFilterData(CollisionFilters.WEAKBOX, CollisionFilters.HITBOX, 0);
	self._weakboxFixture:setSensor(true);
	self._weakboxShape = shape;
end

Entity.removeWeakboxPhysics = function(self)
	if self._weakboxFixture then
		self._weakboxFixture:destroy();
	end
	self._weakboxFixture = nil;
	self._weakboxShape = nil;
end

-- TRIGGER COMPONENT
Entity.removeTrigger = function(self)
	if self._triggerFixture then
		self._triggerFixture:destroy(); -- TODO important do this when component is unregistered
	end
	self._triggerFixture = nil;
	self._triggerShape = nil;
end

-- SPRITE COMPONENT

Entity.setUseSpriteHitboxData = function(self, enabled)
	self._useSpriteHitboxData = enabled;
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

Entity.addSkill = function(self, skill)
	assert(self._combatData);
	self._combatData:addSkill(skill);
end

Entity.setSkill = function(self, index, skill)
	assert(self._combatData);
	self._combatData:setSkill(index, skill);
end

Entity.getSkill = function(self, index)
	assert(self._combatData);
	return self._combatData:getSkill(index);
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

-- CORE

Entity.update = function(self, dt)
	-- if self._scriptRunner then
	-- 	self._scriptRunner:update(dt);
	-- end
	-- if self._sprite then
	-- 	local animationWasOver = self._sprite:isAnimationOver();
	-- 	self._sprite:update(dt);
	-- 	if not animationWasOver and self._sprite:isAnimationOver() then
	-- 		self:signal("animationEnd");
	-- 	end
	-- 	if self._useSpriteHitboxData then
	-- 		local hitShape = self._sprite:getTagShape("hit");
	-- 		if hitShape then
	-- 			self:addHitboxPhysics(hitShape);
	-- 		else
	-- 			self:removeHitboxPhysics();
	-- 		end
	-- 		local weakShape = self._sprite:getTagShape("weak");
	-- 		if weakShape then
	-- 			self:addWeakboxPhysics(weakShape);
	-- 		else
	-- 			self:removeWeakboxPhysics();
	-- 		end
	-- 	end
	-- end
end

Entity.getScene = function(self)
	return self._ecs;
end

return Entity;
