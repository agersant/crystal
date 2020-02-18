require("engine/utils/OOP");
local Log = require("engine/dev/Log");
local Thread = require("engine/script/Thread");
local TableUtils = require("engine/utils/TableUtils");

local Script = Class("Script");

local pumpThread;

local blockThread = function(self, thread, signals)
	assert(self == thread:getOwner());
	for _, signal in ipairs(signals) do
		assert(type(signal) == "string");
		thread:blockOnSignal(signal);
		if not self._blockedThreads[signal] then
			self._blockedThreads[signal] = {};
		end
		self._blockedThreads[signal][thread] = true;
	end
end

local unblockThread = function(self, thread, signal, ...)
	assert(self == thread:getOwner());
	assert(thread:isBlocked());
	local blockedBySignals = thread:getBlockedBySignals();
	for signal in pairs(blockedBySignals) do
		self._blockedThreads[signal][thread] = nil;
	end
	local signalData = {...};
	if TableUtils.countKeys(blockedBySignals) > 1 then
		table.insert(signalData, 1, signal);
	end
	thread:unblock();
	pumpThread(thread:getOwner(), thread, signalData);
end

local endThreadOn = function(self, thread, signals)
	assert(self == thread:getOwner());
	for _, signal in ipairs(signals) do
		assert(type(signal) == "string");
		if not self._endableThreads[signal] then
			self._endableThreads[signal] = {};
		end
		self._endableThreads[signal][thread] = true;
		thread:endOnSignal(signal);
	end
end

local joinThreadOn = function(self, thread, threadsToJoin)
	assert(self == thread:getOwner());
	for _, otherThread in ipairs(threadsToJoin) do
		if not otherThread:isEnded() then
			thread:joinOnThread(otherThread);
		end
	end
	if not thread:isBlocked() then
		pumpThread(thread:getOwner(), thread, {false});
	end
end

pumpThread = function(self, thread, resumeArgs)
	assert(self == thread:getOwner());
	local threadCoroutine = thread:getCoroutine();
	local status = coroutine.status(threadCoroutine);
	assert(status ~= "running");
	if status == "suspended" and not thread:isEnded() then
		local success, a, b, c;
		if resumeArgs ~= nil then
			assert(type(resumeArgs) == "table");
			success, a, b, c = coroutine.resume(threadCoroutine, resumeArgs);
		else
			success, a, b, c = coroutine.resume(threadCoroutine, thread);
		end
		if not success then
			Log:error(a);
		elseif a == "fork" then
			local functionToThread = b;
			local newThread = Thread:new(self, thread, functionToThread);
			table.insert(self._threads, newThread);
			pumpThread(self, newThread);
			pumpThread(self, thread, newThread);
		elseif a == "waitForSignals" then
			blockThread(self, thread, b);
		elseif a == "endOnSignals" then
			endThreadOn(self, thread, b);
			pumpThread(self, thread);
		elseif a == "join" then
			joinThreadOn(self, thread, b);
		elseif a == "hang" then
			thread:block();
		end
	end

	status = coroutine.status(threadCoroutine);
	if status == "dead" and not thread:isEnded() then
		self:endThread(thread, true);
	end
end

local cleanupThread = function(self, thread)
	for signal, _ in pairs(thread:getEndOnSignals()) do
		self._endableThreads[signal][thread] = nil;
	end
	for signal, _ in pairs(thread:getBlockedBySignals()) do
		self._blockedThreads[signal][thread] = nil;
	end
	for otherThread in pairs(thread:getThreadsJoiningOn()) do
		otherThread._joinedBy[thread] = nil;
	end
end

-- PUBLIC API

Script.init = function(self, scriptFunction)
	self._time = 0;
	self._dt = 0;
	self._threads = {};
	self._blockedThreads = {};
	self._endableThreads = {};
	if scriptFunction then
		self:addThread(scriptFunction);
	end
end

Script.update = function(self, dt)
	self._time = self._time + dt;
	self._dt = dt;

	-- Run existing threads
	for i = #self._threads, 1, -1 do
		local thread = self._threads[i];
		if not thread:isBlocked() then
			pumpThread(self, thread);
		end
	end

	-- Remove dead threads
	for i = #self._threads, 1, -1 do
		local thread = self._threads[i];
		if thread:isDead() then
			cleanupThread(self, thread);
			table.remove(self._threads, i);
		end
	end
end

Script.getTime = function(self)
	return self._time;
end

Script.addThread = function(self, functionToThread)
	local thread = Thread:new(self, nil, functionToThread);
	table.insert(self._threads, thread);
	return thread;
end

Script.addThreadAndRun = function(self, functionToThread)
	local thread = self:addThread(functionToThread);
	pumpThread(self, thread);
	return thread;
end

Script.endThread = function(self, thread, completedExecution)
	assert(self == thread:getOwner());
	if not thread:isEnded() then
		thread:markAsEnded();
	end
	for i, childThread in ipairs(thread:getChildThreads()) do
		self:endThread(childThread, false);
	end
	for otherThread in pairs(thread:getThreadsJoiningOnMe()) do
		otherThread:unblock();
		pumpThread(otherThread:getOwner(), otherThread, {completedExecution});
	end
end

Script.signal = function(self, signal, ...)
	if self._endableThreads[signal] then
		for thread, _ in pairs(self._endableThreads[signal]) do
			if not thread:isEnded() then
				self:endThread(thread, false);
			end
		end
	end
	if self._blockedThreads[signal] then
		local blockedThreadsCopy = TableUtils.shallowCopy(self._blockedThreads[signal]);
		for thread, _ in pairs(blockedThreadsCopy) do
			unblockThread(self, thread, signal, ...);
		end
	end
end

return Script;
