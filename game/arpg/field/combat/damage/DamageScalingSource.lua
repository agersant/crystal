require("engine/utils/OOP");

local DamageScalingSource = Class("DamageScalingSource");

DamageScalingSource.init = function(self, scalingSource)
	assert(scalingSource);
	self._scalingSource = scalingSource;
	self._scalesOffTarget = false;
end

DamageScalingSource.getScalingSource = function(self)
	return self._scalingSource;
end

DamageScalingSource.setIsScalingOffTarget = function(self, scalesOffTarget)
	self._scalesOffTarget = scalesOffTarget;
end

DamageScalingSource.isScalingOffTarget = function(self)
	return self._scalesOffTarget;
end

return DamageScalingSource;
