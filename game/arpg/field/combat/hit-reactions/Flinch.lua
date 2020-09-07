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
		self:setAltitude(0);
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
		fixture:setMask(CollisionFilters.SOLID); -- TODO don't poke around fixture internals from outside Collision component
		fixture:setRestitution(.4);
	end

	local dx = math.cos(direction);
	local dy = math.sin(direction);
	self:getBody():setLinearDamping(20, 0);
	self:getBody():applyLinearImpulse(300 * dx, 300 * dy);

	self:waitTween(0, 6, 0.1, "outCubic", self.setAltitude, self);
	self:waitTween(6, 0, 0.1, "inCubic", self.setAltitude, self);

	self:wait(0.1);
end

local largeFlinch = function(self, direction)
	if self:getComponent(Locomotion) then
		self:scope(self:disableLocomotion());
	end
	self:scope(restorePhysics(self));

	local collision = self:getComponent(Collision);
	local oldMask;
	if collision then
		local fixture = collision:getFixture();
		oldMask = {fixture:getMask()};
		fixture:setMask(CollisionFilters.SOLID);
		fixture:setRestitution(.4);
	end

	self:wait(6 * 1 / 60);

	local dx = math.cos(direction);
	local dy = math.sin(direction);

	self:getBody():setLinearDamping(4, 0);
	self:getBody():applyLinearImpulse(400 * dx, 400 * dy);

	self:waitTween(0, 16, 0.15, "outQuadratic", self.setAltitude, self);
	self:waitTween(16, 0, 0.15, "inQuadratic", self.setAltitude, self);
	self:waitTween(0, 4, 0.1, "outQuadratic", self.setAltitude, self);
	self:waitTween(4, 0, 0.1, "inQuadratic", self.setAltitude, self);
	self:waitTween(0, 2, 0.08, "outQuadratic", self.setAltitude, self);
	self:waitTween(2, 0, 0.08, "inQuadratic", self.setAltitude, self);

	if collision then
		local fixture = collision:getFixture();
		fixture:setMask(unpack(oldMask));
	end

	self:wait(0.6);
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
