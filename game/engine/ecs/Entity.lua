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

Entity.awake = function(self)
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

Entity.getZ = function(self)
	assert(self._body);
	return self._body:getY();
end

Entity.getScreenPosition = function(self)
	local x, y = self:getPosition();
	local camera = self:getScene():getCamera();
	return camera:getRelativePosition(x, y);
end

Entity.findPathTo = function(self, targetX, targetY)
	local startX, startY = self:getPosition();
	return self._ecs:findPath(startX, startY, targetX, targetY);
end

-- LOCOMOTION COMPONENT

Entity.setMovementSpeed = function(self, speed)
	return self._movementStat:setValue(speed);
end

Entity.getMovementSpeed = function(self)
	return self._movementStat:getValue();
end

-- COLLISION COMPONENT

Entity.addCollisionPhysics = function(self)
	assert(self:getBody());
	assert(not self._collisionFixture);
	local collisionShape = love.physics.newCircleShape(1);
	self._collisionFixture = love.physics.newFixture(self:getBody(), collisionShape);
	self._collisionFixture:setFilterData(CollisionFilters.SOLID,
                                     	CollisionFilters.GEO + CollisionFilters.SOLID + CollisionFilters.TRIGGER, 0);
	self._collisionFixture:setFriction(0);
	self._collisionFixture:setRestitution(0);
end

Entity.setCollisionRadius = function(self, radius)
	assert(radius > 0);
	assert(self._collisionFixture);
	self._collisionFixture:getShape():setRadius(radius);
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
		self._triggerFixture:destroy(); -- TODO important do this when component is deregistered
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

Entity.isUpdatable = function(self)
	return self._scriptRunner or self._sprite or (self.update ~= Entity.update);
end

Entity.isDrawable = function(self)
	return self._sprite or self._body or (self.draw ~= Entity.draw);
end

Entity.isCombatable = function(self)
	return self._combatData;
end

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

Entity.draw = function(self)
	if self._sprite and self._body then
		self._sprite:draw(self._body:getX(), self._body:getY());
	end
	if DebugFlags.drawPhysics then
		if self._collisionFixture then
			self:drawShape(self._collisionFixture:getShape(), Colors.cyan);
		end
		if self._hitboxFixture then
			self:drawShape(self._hitboxFixture:getShape(), Colors.strawberry);
		end
		if self._weakboxFixture then
			self:drawShape(self._weakboxFixture:getShape(), Colors.ecoGreen);
		end
		if self._triggerFixture then
			self:drawShape(self._triggerFixture:getShape(), Colors.ecoGreen);
		end
	end
end

Entity.destroy = function(self)
	if self._body then
		self._body:destroy(); -- TODO do this when component is unregistered
	end
end

Entity.getScene = function(self)
	return self._ecs;
end

return Entity;
