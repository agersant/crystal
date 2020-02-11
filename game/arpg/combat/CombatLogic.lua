require("engine/utils/OOP");
local Stat = require("arpg/combat/Stat");
local Damage = require("arpg/combat/Damage");
local Teams = require("arpg/combat/Teams");
local Component = require("engine/ecs/Component");

local CombatLogic = Class("CombatLogic", Component);

-- IMPLEMENTATION

local mitigateDamage = function(self, damage)
	local rawAmount = damage:getAmount();
	local defense = self._defense:getValue();
	local mitigationFactor = defense / (defense + 100);
	local mitigatedAmount = rawAmount * (1 - mitigationFactor);
	return math.ceil(mitigatedAmount);
end

-- PUBLIC API

CombatLogic.init = function(self)
	CombatLogic.super.init(self);
	self:setTeam(Teams.wild);
	self._health = Stat:new(50, 0, nil);
	self._defense = Stat:new(10, 1, nil);
	self._strength = Stat:new(10, 1, nil);
	self._attackRating = Stat:new(1.5, 0, nil);
	self._critRate = Stat:new(.02, 0, 1);
	self._critRating = Stat:new(2, 1, nil);
end

CombatLogic.setTeam = function(self, team)
	assert(Teams:isValid(team));
	self._team = team;
end

CombatLogic.getTeam = function(self)
	return self._team;
end

CombatLogic.inflictDamageTo = function(self, target)
	local effectiveStrength = self._strength:getValue() * self._attackRating:getValue();
	local isCrit = math.random() < self._critRate:getValue();
	if isCrit then
		effectiveStrength = effectiveStrength * self._critRating:getValue();
	end
	local damage = Damage:new(effectiveStrength, self:getEntity());
	target:receiveDamage(damage);
end

CombatLogic.receiveDamage = function(self, damage)
	if self:isDead() then
		return;
	end
	local effectiveDamage = mitigateDamage(self, damage);
	self._health:substract(effectiveDamage);
end

CombatLogic.getHealth = function(self)
	return self._health:getValue();
end

CombatLogic.kill = function(self)
	self._health:setValue(0);
end

CombatLogic.isDead = function(self)
	return self._health:getValue() == 0;
end

return CombatLogic;
