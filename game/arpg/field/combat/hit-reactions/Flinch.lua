require("engine/utils/OOP");
local FlinchAmounts = require("arpg/field/combat/hit-reactions/FlinchAmounts");
local Component = require("engine/ecs/Component");
local Collision = require("engine/mapscene/physics/Collision");
local CollisionFilters = require("engine/mapscene/physics/CollisionFilters");
local Actor = require("engine/mapscene/behavior/Actor");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");
local Locomotion = require("engine/mapscene/physics/Locomotion");

local Flinch = Class("Flinch", Component);

Flinch.init = function(self)
	Flinch.super.init(self);
end

local restorePhysics = function(self)
	local collision = self:getComponent(Collision);
	local fixture, oldMask, oldRestitution;
	if collision then
		fixture = collision:getFixture();
		oldMask = {fixture:getMask()};
		oldRestitution = fixture:getRestitution();
	end
	local dampingX, dampingY = self:getBody():getLinearDamping();
	return function()
		if fixture then
			fixture:setMask(unpack(oldMask));
			fixture:setRestitution(oldRestitution);
		end
		self:getBody():setLinearDamping(dampingX, dampingY);
	end
end

local smallFlinch = function(self, direction)
	if self:getComponent(Locomotion) then
		self:scope(self:disableLocomotion());
	end
	self:scope(restorePhysics(self));

	local collision = self:getComponent(Collision);
	if collision then
		local fixture = collision:getFixture();
		fixture:setMask(CollisionFilters.SOLID);
		fixture:setRestitution(.4);
	end

	local dx = math.cos(direction);
	local dy = math.sin(direction);
	self:getBody():setLinearDamping(60, 0);
	self:getBody():applyLinearImpulse(800 * dx, 800 * dy);

	self:wait(0.3);
end

local largeFlinch = function(self, direction)
	if self:getComponent(Locomotion) then
		self:scope(self:disableLocomotion());
	end
	self:scope(restorePhysics(self));

	local collision = self:getComponent(Collision);
	if collision then
		local fixture = collision:getFixture();
		fixture:setMask(CollisionFilters.SOLID);
		fixture:setRestitution(.4);
	end

	self:wait(5 * 1 / 60);

	local dx = math.cos(direction);
	local dy = math.sin(direction);
	self:getBody():setLinearDamping(15, 0);
	self:getBody():applyLinearImpulse(1200 * dx, 1200 * dy);

	self:wait(0.4);
end

Flinch.beginFlinch = function(self, direction, amount)
	assert(direction);
	assert(amount);
	if self._flinchAmount and self._flinchAmount > amount then
		return;
	end

	local entity = self:getEntity();
	assert(entity:getComponent(Actor));
	assert(entity:getComponent(PhysicsBody));

	if entity:isIdle() or self._flinchAmount then
		entity:stopAction();
		if amount == FlinchAmounts.LARGE then
			entity:doAction(function(self)
				self:scope(self:setFlinchAmount(amount));
				largeFlinch(self, direction)
			end);
		else
			entity:doAction(function(self)
				self:scope(self:setFlinchAmount(amount));
				smallFlinch(self, direction)
			end);
		end
	end
end

Flinch.getFlinchAmount = function(self, amount)
	return self._flinchAmount;
end

Flinch.setFlinchAmount = function(self, amount)
	self._flinchAmount = amount;
	return function()
		self:setFlinchAmount();
	end
end

return Flinch;
