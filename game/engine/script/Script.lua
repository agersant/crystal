require("engine/utils/OOP");
local Log = require("engine/dev/Log");
local Thread = require("engine/script/Thread");
local TableUtils = require("engine/utils/TableUtils");

local Script = Class("Script");

local pumpThread;

local blockThread = function(self, thread, signals)
	assert(self == thread:getScript());
	for _, signal in ipairs(signals) do
		assert(type(signal) == "string");
		thread:blockOnSignal(signal);
		if not self._blockingSignals[signal] then
			self._blockingSignals[signal] = {};
		end
		self._blockingSignals[signal][thread] = true;
	end
end

local unblockThread = function(self, thread, signal, ...)
	assert(self == thread:getScript());
	assert(thread:isBlocked());
	local signals = thread:getBlockingSignals();
	for signal in pairs(signals) do
		self._blockingSignals[signal][thread] = nil;
	end
	local signalData = {...};
	if TableUtils.countKeys(signals) > 1 then
		table.insert(signalData, 1, signal);
	end
	thread:unblock();
	pumpThread(thread, signalData);
end

local endThreadOn = function(self, thread, signals)
	assert(self == thread:getScript());
	for _, signal in ipairs(signals) do
		assert(type(signal) == "string");
		if not self._endingSignals[signal] then
			self._endingSignals[signal] = {};
		end
		self._endingSignals[signal][thread] = true;
		thread:endOnSignal(signal);
	end
end

local joinThreadOn = function(self, thread, threadsToJoin)
	assert(self == thread:getScript());
	assert(#threadsToJoin > 0);
	for _, otherThread in ipairs(threadsToJoin) do
		if otherThread:isEnded() then
			pumpThread(thread, otherThread:getOutput());
			return;
		end
	end
	for _, otherThread in ipairs(threadsToJoin) do
		if not otherThread:isEnded() then
			thread:blockOnThread(otherThread);
		end
	end
	assert(thread:isBlocked());
end

pumpThread = function(thread, resumeArgs)
	local self = thread:getScript();
	local threadCoroutine = thread:getCoroutine();
	local status = coroutine.status(threadCoroutine);
	assert(status ~= "running");
	local results;
	if status == "suspended" and not thread:isEnded() and not thread:isBlocked() then
		if resumeArgs ~= nil then
			assert(type(resumeArgs) == "table");
			results = {coroutine.resume(threadCoroutine, resumeArgs)};
		else
			results = {coroutine.resume(threadCoroutine, thread)};
		end
		local success = results[1];
		if not success then
			local errorText = results[2];
			Log:error(errorText);
			Log:error(debug.traceback(threadCoroutine));
		else
			local instruction = results[2];
			if instruction == "fork" then
				local newThread = results[3];
				assert(newThread:isInstanceOf(Thread));
				self._threads[newThread] = true;
				pumpThread(newThread);
				pumpThread(thread, newThread);
			elseif instruction == "waitForSignals" then
				local signals = results[3];
				blockThread(self, thread, signals);
			elseif instruction == "endOnSignals" then
				local signals = results[3];
				endThreadOn(self, thread, signals);
				pumpThread(thread);
			elseif instruction == "join" then
				local threads = results[3];
				joinThreadOn(self, thread, threads);
			elseif instruction == "hang" then
				thread:block();
			end
		end
	end

	status = coroutine.status(threadCoroutine);
	if status == "dead" and not thread:isEnded() then
		thread:setOutput(results);
		self:endThread(thread);
	end
end

local cleanupThread = function(self, thread)
	for signal, _ in pairs(thread:getEndOnSignals()) do
		self._endingSignals[signal][thread] = nil;
	end
	for signal, _ in pairs(thread:getBlockingSignals()) do
		self._blockingSignals[signal][thread] = nil;
	end
	self._threads[thread] = nil;
end

Script.init = function(self, scriptFunction)
	self._time = 0;
	self._threads = {};
	self._blockingSignals = {};
	self._endingSignals = {};
	if scriptFunction then
		self:addThread(scriptFunction);
	end
end

Script.update = function(self, dt)
	self._time = self._time + dt;
	local threads = TableUtils.shallowCopy(self._threads);
	for thread in pairs(threads) do
		pumpThread(thread);
	end
end

Script.stop = function(self)
	local threads = TableUtils.shallowCopy(self._threads);
	for thread in pairs(threads) do
		self:endThread(thread);
	end
end

Script.getTime = function(self)
	return self._time;
end

Script.addThread = function(self, functionToThread)
	local thread = Thread:new(self, nil, functionToThread);
	self._threads[thread] = true;
	return thread;
end

Script.addThreadAndRun = function(self, functionToThread)
	local thread = self:addThread(functionToThread);
	pumpThread(thread);
	return thread;
end

Script.endThread = function(self, thread)
	assert(self == thread:getScript());
	if not thread:isEnded() then
		thread:markAsEnded();
	end
	for i, childThread in ipairs(thread:getChildThreads()) do
		self:endThread(childThread);
	end
	local cleanupFunctions = thread:getCleanupFunctions();
	for i = #cleanupFunctions, 1, -1 do
		cleanupFunctions[i]();
	end
	cleanupThread(self, thread);
	for otherThread in pairs(thread:getThreadsJoiningOnMe()) do
		otherThread:unblock();
		pumpThread(otherThread, thread:getOutput() or {false});
	end
end

Script.signal = function(self, signal, ...)
	if self._endingSignals[signal] then
		for thread, _ in pairs(self._endingSignals[signal]) do
			if not thread:isEnded() then
				self:endThread(thread);
			end
		end
	end
	if self._blockingSignals[signal] then
		local blockedThreadsCopy = TableUtils.shallowCopy(self._blockingSignals[signal]);
		for thread, _ in pairs(blockedThreadsCopy) do
			unblockThread(self, thread, signal, ...);
		end
	end
end

return Script;
