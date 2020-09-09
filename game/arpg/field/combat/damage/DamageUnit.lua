require("engine/utils/OOP");
local DamageTypes = require("arpg/field/combat/damage/DamageTypes");
local Elements = require("arpg/field/combat/damage/Elements");
local DamageScalingSource = require("arpg/field/combat/damage/DamageScalingSource");
local ScalingSources = require("arpg/field/combat/stats/ScalingSources");

local DamageUnit = Class("DamageUnit");

DamageUnit.init = function(self, flatAmount, damageType, element)
	self._damageType = damageType or DamageTypes.PHYSICAL;
	self._element = element or Elements.UNASPECTED;
	self._flatAmount = flatAmount or 0;
	self._scalingRatio = 0;
	self._damageScalingSource = DamageScalingSource:new(ScalingSources.OFFENSE_PHYSICAL);
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

DamageUnit.getDamageScalingSource = function(self)
	return self._damageScalingSource;
end

DamageUnit.setScalingAmount = function(self, ratio, damageScalingSource)
	assert(ratio);
	assert(damageScalingSource);
	assert(damageScalingSource:isInstanceOf(DamageScalingSource));
	self._scalingRatio = ratio;
	self._damageScalingSource = damageScalingSource;
end

return DamageUnit;
