require("engine/utils/OOP");
local Alias = require("engine/utils/Alias");
local MathUtils = require("engine/utils/MathUtils");

local Thread = Class("Thread");

Thread.init = function(self, owner, parentThread, functionToThread)
	assert(type(functionToThread) == "function");
	local threadCoroutine = coroutine.create(functionToThread);

	self._coroutine = threadCoroutine;
	self._owner = owner;
	self._childThreads = {};
	self._blockedBy = {};
	self._endsOn = {};
	self._joinedBy = {};
	self._joiningOn = {};
	self._cleanupFunctions = {};

	if parentThread then
		parentThread._childThreads[self] = true;
		self._parentThread = parentThread;
	end

	Alias:add(self, owner);
end

Thread.getOwner = function(self)
	return self._owner;
end

Thread.getCoroutine = function(self)
	return self._coroutine;
end

Thread.isDead = function(self)
	return coroutine.status(self._coroutine) == "dead" or self._isEnded;
end

Thread.isBlocked = function(self)
	return self._isBlocked;
end

Thread.block = function(self)
	self._isBlocked = true;
end

Thread.blockOnSignal = function(self, signal)
	self._isBlocked = true;
	self._blockedBy[signal] = true;
end

Thread.unblock = function(self)
	assert(self.isBlocked);
	self._isBlocked = false;
	self._blockedBy = {};
end

Thread.endOnSignal = function(self, signal)
	self._endsOn[signal] = true;
end

Thread.joinOnThread = function(self, otherThread)
	assert(not otherThread._isEnded);
	self._isBlocked = true;
	self._joiningOn[otherThread] = true;
	otherThread._joinedBy[self] = true;
end

Thread.markAsEnded = function(self)
	self._isEnded = true;
	for childThread in pairs(self._childThreads) do
		childThread:markAsEnded();
	end
end

Thread.getChildThreads = function(self)
	return self._childThreads;
end

Thread.getThreadsJoiningOnMe = function(self)
	return self._joinedBy;
end

Thread.getEndOnSignals = function(self)
	return self._endsOn;
end

Thread.getBlockedBySignals = function(self)
	return self._blockedBy;
end

Thread.isEnded = function(self)
	return self._isEnded;
end

Thread.getThreadsJoiningOn = function(self)
	return self._joiningOn;
end

Thread.getCleanupFunctions = function(self)
	return self._cleanupFunctions;
end

Thread.waitFrame = function(self)
	coroutine.yield();
end

Thread.wait = function(self, seconds)
	local endTime = self._owner:getTime() + seconds;
	while self._owner:getTime() < endTime do
		coroutine.yield();
	end
end

Thread.thread = function(self, functionToThread)
	assert(type(functionToThread) == "function");
	return coroutine.yield("fork", functionToThread);
end

Thread.waitFor = function(self, signal)
	assert(type(signal) == "string");
	return self:waitForAny({signal});
end

Thread.waitForAny = function(self, signals)
	assert(type(signals) == "table");
	local returns = coroutine.yield("waitForSignals", signals);
	return unpack(returns);
end

Thread.endOn = function(self, signal)
	assert(type(signal) == "string");
	return self:endOnAny({signal});
end

Thread.endOnAny = function(self, signals)
	assert(type(signals) == "table");
	coroutine.yield("endOnSignals", signals);
end

Thread.join = function(self, thread)
	assert(thread);
	return self:joinAny({thread});
end

Thread.joinAny = function(self, threads)
	local returns = coroutine.yield("join", threads);
	return unpack(returns);
end

Thread.hang = function(self)
	coroutine.yield("hang");
end

Thread.stop = function(self)
	assert(not self:isDead());
	self._owner:endThread(self, false);
end

Thread.scope = function(self, cleanupFunction)
	assert(type(cleanupFunction) == "function");
	table.insert(self._cleanupFunctions, cleanupFunction);
end

Thread.tween = function(self, from, to, duration, easing, set)
	assert(duration >= 0);
	if duration == 0 then
		set(to);
		return;
	end
	local startTime = self._owner:getTime();
	while self._owner:getTime() <= startTime + duration do
		local t = (self._owner:getTime() - startTime) / duration;
		local t = MathUtils.ease(t, easing);
		local currentValue = from + t * (to - from);
		set(currentValue);
		self:waitFrame();
	end
end

return Thread;
