local Alias = require("utils/Alias");
local MathUtils = require("utils/MathUtils");
local TableUtils = require("utils/TableUtils");

local Thread = Class("Thread");

Thread.init = function(self, script, parentThread, functionToThread)
	assert(type(functionToThread) == "function");

	self._coroutine = coroutine.create(functionToThread);
	self._script = script;
	self._childThreads = {};
	self._blockingSignals = {};
	self._endingSignals = {};
	self._joinedBy = {};
	self._cleanupFunctions = {};

	if parentThread then
		parentThread._childThreads[self] = true;
	end

	Alias:add(self, script);
end

Thread.getScript = function(self)
	return self._script;
end

Thread.getCoroutine = function(self)
	return self._coroutine;
end

Thread.isDead = function(self)
	return coroutine.status(self._coroutine) == "dead" or self._isEnded;
end

Thread.setOutput = function(self, output)
	self._output = output;
end

Thread.getOutput = function(self, output)
	return self._output;
end

Thread.isBlocked = function(self)
	return self._isBlocked;
end

Thread.blockOnSignal = function(self, signal)
	self._isBlocked = true;
	self._blockingSignals[signal] = true;
end

Thread.blockOnThread = function(self, otherThread)
	assert(not otherThread._isEnded);
	self._isBlocked = true;
	otherThread._joinedBy[self] = true;
end

Thread.unblock = function(self)
	assert(self.isBlocked);
	self._isBlocked = false;
	self._blockingSignals = {};
end

Thread.endOnSignal = function(self, signal)
	self._endingSignals[signal] = true;
end

Thread.markAsEnded = function(self)
	self._isEnded = true;
	for childThread in pairs(self._childThreads) do
		childThread:markAsEnded();
	end
end

Thread.isEnded = function(self)
	return self._isEnded;
end

Thread.getChildThreads = function(self)
	return self._childThreads;
end

Thread.getThreadsJoiningOnMe = function(self)
	return self._joinedBy;
end

Thread.getEndingSignals = function(self)
	return self._endingSignals;
end

Thread.getBlockingSignals = function(self)
	return self._blockingSignals;
end

Thread.runCleanupFunctions = function(self)
	local cleanupFunctions = TableUtils.shallowCopy(self._cleanupFunctions);
	for i = #cleanupFunctions, 1, -1 do
		cleanupFunctions[i]();
	end
end

Thread.waitFrame = function(self)
	coroutine.yield("waitFrame");
end

Thread.wait = function(self, seconds)
	local endTime = self._script:getTime() + seconds;
	while self._script:getTime() < endTime do
		coroutine.yield("wait");
	end
end

Thread.thread = function(self, functionToThread)
	assert(not self:isDead());
	assert(type(functionToThread) == "function");
	local newThread = Thread:new(self._script, self, functionToThread)
	return coroutine.yield("fork", newThread);
end

Thread.waitFor = function(self, signal)
	assert(not self:isDead());
	assert(type(signal) == "string");
	return self:waitForAny({ signal });
end

Thread.waitForAny = function(self, signals)
	assert(not self:isDead());
	assert(type(signals) == "table");
	local returns = coroutine.yield("waitForSignals", signals);
	return unpack(returns);
end

Thread.endOn = function(self, signal)
	assert(not self:isDead());
	assert(type(signal) == "string");
	return self:endOnAny({ signal });
end

Thread.endOnAny = function(self, signals)
	assert(not self:isDead());
	assert(type(signals) == "table");
	coroutine.yield("endOnSignals", signals);
end

Thread.join = function(self, thread)
	assert(not self:isDead());
	assert(thread);
	return self:joinAny({ thread });
end

Thread.joinAny = function(self, threads)
	assert(not self:isDead());
	local returns = coroutine.yield("join", threads);
	return unpack(returns);
end

Thread.hang = function(self)
	assert(not self:isDead());
	self._isBlocked = true;
	coroutine.yield("hang");
end

Thread.stop = function(self)
	assert(not self:isDead());
	self._script:stopThread(self, false);
end

Thread.abort = function(self)
	assert(self:isEnded());
	if coroutine.running() == self._coroutine then
		coroutine.yield("abort");
	end
end

Thread.scope = function(self, cleanupFunction)
	assert(not self:isDead());
	assert(type(cleanupFunction) == "function");
	table.insert(self._cleanupFunctions, cleanupFunction);
end

Thread.tween = function(self, from, to, duration, easing, callback, arg)
	return self:thread(function(self)
		self:waitTween(from, to, duration, easing, callback, arg);
	end);
end

Thread.waitTween = function(self, from, to, duration, easing, callback, arg)
	assert(duration >= 0);
	if duration == 0 then
		if arg then
			callback(arg, to);
		else
			callback(to);
		end
		return;
	end
	local startTime = self._script:getTime();
	while self._script:getTime() <= startTime + duration do
		local t = (self._script:getTime() - startTime) / duration;
		local t = MathUtils.ease(t, easing);
		local currentValue = from + t * (to - from);
		if arg then
			callback(arg, currentValue);
		else
			callback(currentValue);
		end
		self:waitFrame();
	end
end

return Thread;
