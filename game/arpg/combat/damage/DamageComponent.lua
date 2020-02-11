require("engine/utils/OOP");
local DamageTypes = require("arpg/combat/damage/DamageTypes");
local Elements = require("arpg/combat/damage/Elements");
local DamageScalingSources = require("arpg/combat/damage/DamageScalingSources");

local DamageComponent = Class("DamageComponent");

-- PUBLIC API

DamageComponent.init = function(self, flatAmount, damageType, element)
	self._damageType = damageType or DamageTypes.PHYSICAL;
	self._element = element or Elements.UNASPECTED;
	self._flatAmount = flatAmount or 0;
	self._scalingRatio = 0;
	self._scalingSource = DamageScalingSources.ATTACKER_ATTACK;
end

DamageComponent.getDamageType = function(self)
	return self._damageType;
end

DamageComponent.getElement = function(self)
	return self._element;
end

DamageComponent.getFlatAmount = function(self, amount)
	return self._flatAmount;
end

DamageComponent.setFlatAmount = function(self, amount)
	self._flatAmount = amount;
end

DamageComponent.getScalingRatio = function(self)
	return self._scalingRatio;
end

DamageComponent.getScalingSource = function(self)
	return self._scalingSource;
end

DamageComponent.setScalingAmount = function(self, ratio, scalingSource)
	assert(ratio);
	assert(scalingSource);
	self._scalingRatio = ratio;
	self._scalingSource = scalingSource;
end

return DamageComponent;
