require("engine/utils/OOP");

local StatModifier = Class("StatModifier");

StatModifier.init = function(self, stat, flatAmount)
	assert(stat);
	self._stat = stat;
	self._flatAmount = flatAmount or 0;
	self._scalingRatio = 0;
	self._scalingSource = self._stat;
end

StatModifier.getStat = function(self)
	return self._stat;
end

StatModifier.getFlatAmount = function(self, amount)
	return self._flatAmount;
end

StatModifier.setFlatAmount = function(self, amount)
	self._flatAmount = amount;
end

StatModifier.getScalingRatio = function(self)
	return self._scalingRatio;
end

StatModifier.getScalingSource = function(self)
	return self._scalingSource;
end

StatModifier.setScalingAmount = function(self, ratio, scalingSource)
	assert(ratio);
	assert(scalingSource);
	self._scalingRatio = ratio;
	self._scalingSource = scalingSource;
end

return StatModifier;
