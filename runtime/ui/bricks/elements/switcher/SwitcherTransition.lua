local SwitcherTransition = Class("SwitcherTransition");

SwitcherTransition.init = function(self, duration, easing)
	self._duration = duration or 0;
	self._easing = easing or math.ease_out_quadratic;
	self._script = crystal.Script:new();
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

	self._script:stop_all_threads();
	return self._script:run_thread(function(self)
		self:wait_tween(0, 1, duration, easing, transition.setProgress, transition);
	end);
end

SwitcherTransition.skipToEnd = function(self)
	self:setProgress(1);
	self._script:stop_all_threads();
end

SwitcherTransition.handleChildRemoved = function(self, child)
	if self._from == child then
		self._from = nil;
	end
	if self._to == child then
		self._to = nil;
	end
end

SwitcherTransition.compute_desired_size = function(self)
	local fromWidth = 0;
	local fromHeight = 0;
	if self._from then
		local joint = self._from:joint();
		local child_width, child_height = self._from:desired_size();
		fromWidth, fromHeight = joint:compute_desired_size(child_width, child_height);
	end

	local toWidth = 0;
	local toHeight = 0;
	if self._to then
		local joint = self._to:joint();
		local child_width, child_height = self._to:desired_size();
		toWidth, toHeight = joint:compute_desired_size(child_width, child_height);
	end

	local t = self:getProgress();
	return math.lerp(fromWidth, toWidth, t), math.lerp(fromHeight, toHeight, t);
end

SwitcherTransition.draw = function(self, width, height)
	if self._to then
		self._to:draw();
	end
end

return SwitcherTransition;
