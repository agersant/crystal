require("engine/utils/OOP");
local DamageTypes = require("arpg/combat/damage/DamageTypes");
local Elements = require("arpg/combat/damage/Elements");
local DamageScalingSources = require("arpg/combat/damage/DamageScalingSources");

local DamageUnit = Class("DamageUnit");

-- PUBLIC API

DamageUnit.init = function(self, flatAmount, damageType, element)
	self._damageType = damageType or DamageTypes.PHYSICAL;
	self._element = element or Elements.UNASPECTED;
	self._flatAmount = flatAmount or 0;
	self._scalingRatio = 0;
	self._scalingSource = DamageScalingSources.ATTACKER_ATTACK;
end

DamageUnit.getDamageType = function(self)
	return self._damageType;
end

DamageUnit.getElement = function(self)
	return self._element;
end

DamageUnit.getFlatAmount = function(self, amount)
	return self._flatAmount;
end

DamageUnit.setFlatAmount = function(self, amount)
	self._flatAmount = amount;
end

DamageUnit.getScalingRatio = function(self)
	return self._scalingRatio;
end

DamageUnit.getScalingSource = function(self)
	return self._scalingSource;
end

DamageUnit.setScalingAmount = function(self, ratio, scalingSource)
	assert(ratio);
	assert(scalingSource);
	self._scalingRatio = ratio;
	self._scalingSource = scalingSource;
end

return DamageUnit;
