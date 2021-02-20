require("engine/utils/OOP");
local Script = require("engine/script/Script");

local SwitcherTransition = Class("SwitcherTransition");

SwitcherTransition.init = function(self, duration, easing)
	self._duration = duration or 0;
	self._easing = easing or "outQuadratic";
	self._script = Script:new();
	self._progress = 0;
	self._from = nil;
	self._to = nil;
end

SwitcherTransition.setProgress = function(self, progress)
	assert(progress >= 0);
	assert(progress <= 1);
	self._progress = progress;
end

SwitcherTransition.getProgress = function(self)
	return self._progress;
end

SwitcherTransition.isOver = function(self)
	return self._progress >= 1;
end

SwitcherTransition.getDuration = function(self)
	return self._duration;
end

SwitcherTransition.getEasing = function(self)
	return self._easing;
end

SwitcherTransition.update = function(self, dt)
	self._script:update(dt);
end

SwitcherTransition.play = function(self, from, to)
	self._from = from;
	self._to = to;

	local duration = self:getDuration();
	local easing = self:getEasing();
	local transition = self;

	self._script:stopAllThreads();
	return self._script:addThreadAndRun(function(self)
		self:waitTween(0, 1, duration, easing, transition.setProgress, transition);
	end);
end

SwitcherTransition.skipToEnd = function(self)
	self:setProgress(1);
	self._script:stopAllThreads();
end

SwitcherTransition.handleChildRemoved = function(self, child)
	if self._from == child then
		self._from = nil;
	end
	if self._to == child then
		self._to = nil;
	end
end

SwitcherTransition.computeDesiredSize = function(self)
	if self._to then
		local joint = self._to:getJoint();
		local childWidth, childHeight = self._to:getDesiredSize();
		return joint:computeDesiredSize(childWidth, childHeight);
	end
	return 0, 0;
end

SwitcherTransition.draw = function(self, width, height)
	if self._to then
		self._to:draw();
	end
end

return SwitcherTransition;
