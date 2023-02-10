local Thread = require("script/Thread");
local TableUtils = require("utils/TableUtils");

local Script = Class("Script");

local endThread, pumpThread;

local runningThreads = {};
local healthCheck = function()
	local runningThread = runningThreads[#runningThreads];
	if runningThread and runningThread:isEnded() then
		runningThread:abort();
	end
end

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
	local signalData = { ... };
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
		table.insert(runningThreads, thread);
		if resumeArgs ~= nil then
			assert(type(resumeArgs) == "table");
			results = { coroutine.resume(threadCoroutine, resumeArgs) };
		else
			results = { coroutine.resume(threadCoroutine, thread) };
		end
		table.remove(runningThreads);
		local success = results[1];
		if not success then
			local errorText = results[2];
			crystal.log.error(errorText);
			crystal.log.error(debug.traceback(threadCoroutine));
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
			elseif instruction == "abort" then
				assert(thread:isEnded());
			end
		end
	end

	status = coroutine.status(threadCoroutine);
	if status == "dead" and not thread:isEnded() then
		thread:setOutput(results);
		endThread(self, thread);
	end
end

local cleanupThread = function(self, thread)
	for signal, _ in pairs(thread:getEndingSignals()) do
		self._endingSignals[signal][thread] = nil;
	end
	for signal, _ in pairs(thread:getBlockingSignals()) do
		self._blockingSignals[signal][thread] = nil;
	end
	self._threads[thread] = nil;
end

endThread = function(self, thread)
	assert(self == thread:getScript());
	if not thread:isEnded() then
		thread:markAsEnded();
	end
	for childThread in pairs(thread:getChildThreads()) do
		endThread(self, childThread);
	end
	thread:runCleanupFunctions();
	cleanupThread(self, thread);
	for otherThread in pairs(thread:getThreadsJoiningOnMe()) do
		otherThread:unblock();
		pumpThread(otherThread, thread:getOutput() or { false });
	end
end

Script.init = function(self, scriptFunction)
	self._dt = 0;
	self._time = 0;
	self._threads = {};
	self._blockingSignals = {};
	self._endingSignals = {};
	if scriptFunction then
		self:addThread(scriptFunction);
	end
end

Script.update = function(self, dt)
	self._dt = dt;
	self._time = self._time + dt;
	local threads = TableUtils.shallowCopy(self._threads);
	for thread in pairs(threads) do
		pumpThread(thread);
	end
end

Script.stopThread = function(self, thread)
	endThread(self, thread);
	healthCheck();
end

Script.stopAllThreads = function(self)
	local threads = TableUtils.shallowCopy(self._threads);
	for thread in pairs(threads) do
		endThread(self, thread);
	end
	healthCheck();
end

Script.getTime = function(self)
	return self._time;
end

Script.getDeltaTime = function(self)
	return self._dt;
end

Script.addThread = function(self, functionToThread)
	local thread = Thread:new(self, nil, functionToThread);
	self._threads[thread] = true;
	return thread;
end

Script.addThreadAndRun = function(self, functionToThread)
	local thread = self:addThread(functionToThread);
	pumpThread(thread);
	healthCheck();
	return thread;
end

Script.signal = function(self, signal, ...)
	if self._endingSignals[signal] then
		for thread in pairs(self._endingSignals[signal]) do
			if not thread:isEnded() then
				endThread(self, thread);
			end
		end
	end
	if self._blockingSignals[signal] then
		local blockedThreadsCopy = TableUtils.shallowCopy(self._blockingSignals[signal]);
		for thread in pairs(blockedThreadsCopy) do
			unblockThread(self, thread, signal, ...);
		end
	end
	healthCheck();
end

--#region Tests

crystal.test.add("Script runs", function()
	local a = 0;
	local script = Script:new(function(self)
			a = a + 1;
		end);
	assert(a == 0);
	script:update(0);
	assert(a == 1);
	script:update(0);
	assert(a == 1);
end);

crystal.test.add("Wait frame", function()
	local a = 0;
	local script = Script:new(function(self)
			self:waitFrame();
			a = a + 1;
		end);
	script:update(0);
	assert(a == 0);
	script:update(0);
	assert(a == 1);
end);

crystal.test.add("Wait duration", function()
	local a = 0;
	local script = Script:new(function(self)
			self:wait(1);
			a = a + 1;
		end);
	script:update(0);
	script:update(0.5);
	assert(a == 0);
	script:update(0.5);
	assert(a == 1);
end);

crystal.test.add("Wait for", function()
	local a = 0;
	local script = Script:new(function(self)
			self:waitFor("testSignal");
			a = a + 1;
		end);
	script:update(0);
	assert(a == 0);
	script:signal("testSignal");
	assert(a == 1);
end);

crystal.test.add("Successive waits", function()
	local a = 0;
	local script = Script:new(function(self)
			self:waitFor("test1");
			a = 1;
			self:waitFor("test2");
			a = 2;
			self:waitFrame();
			a = 3;
		end);
	script:update(0);
	assert(a == 0);
	script:signal("test1");
	assert(a == 1);
	script:update(0);
	assert(a == 1);
	script:signal("test2");
	assert(a == 2);
	script:update(0);
	assert(a == 3);
end);

crystal.test.add("Wait for any", function()
	local a = 0;
	local script = Script:new(function(self)
			self:waitForAny({ "testSignal", "gruik" });
			a = a + 1;
		end);
	script:update(0);
	assert(a == 0);
	script:signal("randomSignal");
	assert(a == 0);
	script:signal("gruik");
	assert(a == 1);
	script:signal("testSignal");
	assert(a == 1);
end);

crystal.test.add("Start thread", function()
	local a = 0;
	local script = Script:new(function(self)
			local t = self:thread(function(self)
					self:waitFrame();
					a = 1;
				end);
			self:wait(1);
		end);
	script:update(0);
	assert(a == 0);
	script:update(0);
	assert(a == 1);
end);

crystal.test.add("Stop thread", function()
	local a = 0;
	local script = Script:new(function(self)
			local t = self:thread(function(self)
					self:waitFrame();
					a = 1;
				end);
			t:stop();
		end);
	script:update(0);
	assert(a == 0);
	script:update(0);
	assert(a == 0);
end);

crystal.test.add("Cannot start thread from stopped thread", function()
	local script = Script:new();
	local t0 = script:addThreadAndRun(function()
		end);
	local success = pcall(function()
			t0:thread(function()
			end);
		end);
	assert(not success);
end);

crystal.test.add("Signal additional data", function()
	local a = 0;
	local script = Script:new(function(self)
			a = self:waitFor("testSignal");
		end);
	assert(a == 0);
	script:update(0);
	assert(a == 0);
	script:signal("testSignal", 1);
	assert(a == 1);
end);

crystal.test.add("Multiple signals additional data", function()
	local a = 0;
	local s = "";
	local script = Script:new(function(self)
			s, a = self:waitForAny({ "testSignal", "gruik" });
		end);
	assert(a == 0);
	script:update(0);
	assert(a == 0);
	script:signal("gruik", 1);
	assert(s == "gruik");
	assert(a == 1);
end);

crystal.test.add("Signal doesn't wake dead threads", function()
	local sentinel = true;
	local script = Script:new(function(self)
			local t0 = self:thread(function(self)
					self:waitFor("s0");
					sentinel = false;
				end);
			local t1 = self:thread(function(self)
					self:waitFor("s1");
					t0:stop();
				end);
		end);
	script:update(0);
	script:signal("s1");
	script:signal("s0");
	assert(sentinel);
end);

crystal.test.add("End on", function()
	local a = 0;
	local script = Script:new(function(self)
			self:endOn("end");
			self:waitFrame();
			a = 1;
		end);
	script:update(0);
	assert(a == 0);
	script:signal("end");
	script:update(0);
	assert(a == 0);
end);

crystal.test.add("Unblock after end on", function()
	local a = 0;
	local script = Script:new(function(self)
			self:endOn("end");
			self:waitFor("signal");
			a = 1;
		end);
	script:update(0);
	assert(a == 0);
	script:signal("end");
	script:signal("signal");
	script:update(0);
	assert(a == 0);
end);

crystal.test.add("Wait for join", function()
	local sentinel = false;
	local script = Script:new();
	local t1 = script:addThreadAndRun(function(self)
			self:waitFor("s1");
			self:waitFor("s2");
		end);
	local t2 = script:addThreadAndRun(function(self)
			self:join(t1);
			sentinel = true;
		end);

	assert(not sentinel);
	script:signal("s1");
	assert(not sentinel);
	script:signal("s2");
	assert(sentinel);
end);

crystal.test.add("Join any", function()
	local sentinel = false;
	local script = Script:new();
	local t1 = script:addThreadAndRun(function(self)
			self:waitFor("s1");
			self:waitFor("s2");
		end);
	local t2 = script:addThreadAndRun(function(self)
			self:waitFor("s3");
		end);
	local t3 = script:addThreadAndRun(function(self)
			self:joinAny({ t1, t2 });
			sentinel = true;
		end);

	assert(not sentinel);
	script:signal("s1");
	assert(not sentinel);
	script:signal("s3");
	assert(sentinel);
end);

crystal.test.add("Join returns true when joined thread completed", function()
	local completed;
	local script = Script:new();
	local t1 = script:addThreadAndRun(function(self)
			self:waitFor("s1");
		end);
	local t2 = script:addThreadAndRun(function(self)
			local c = self:join(t1);
			completed = c;
		end);

	script:update(0);
	assert(completed == nil);
	script:signal("s1");
	assert(completed);
end);

crystal.test.add("Join returns false when joined thread was stopped", function()
	local completed;
	local script = Script:new();
	local t1 = script:addThreadAndRun(function(self)
			self:waitFor("s1");
		end);
	local t2 = script:addThreadAndRun(function(self)
			completed = self:join(t1);
		end);
	local t3 = script:addThreadAndRun(function(self)
			self:waitFor("s2");
			t1:stop();
		end);

	script:update(0);
	assert(completed == nil);
	script:signal("s2");
	assert(completed == false);
end);

crystal.test.add("Join returns thread output", function()
	local completed, sentinel;
	local script = Script:new();
	local t1 = script:addThreadAndRun(function(self)
			self:waitFor("s1");
			return 10;
		end);
	local t2 = script:addThreadAndRun(function(self)
			completed, sentinel = self:join(t1);
		end);

	assert(completed == nil);
	assert(sentinel == nil);
	script:update(0);
	assert(completed == nil);
	assert(sentinel == nil);
	script:signal("s1");
	assert(completed == true);
	assert(sentinel == 10);
end);

crystal.test.add("Join doesn't unblock when parent thread is in the process of stopping", function()
	local sentinel;
	local script = Script:new();
	local t0 = script:addThreadAndRun(function(self)
			local t01 = self:thread(function(self)
					self:hang();
				end);
			self:thread(function(self)
				self:join(t01);
				sentinel = false;
			end);
			self:hang();
		end);
	local t1 = script:addThreadAndRun(function(self)
			self:waitFor("s1");
			sentinel = true;
			t0:stop();
		end);

	script:update(0);
	assert(sentinel == nil);
	script:signal("s1");
	assert(sentinel);
end);

crystal.test.add("Joining dead threads is no-op", function()
	local sentinel;
	local script = Script:new();
	local t0 = script:addThreadAndRun(function(self)
		end);
	local t1 = script:addThreadAndRun(function(self)
		end);
	local t2 = script:addThreadAndRun(function(self)
			self:waitFor("s1");
			self:join(t0);
			self:join(t1);
			sentinel = true;
		end);

	script:update(0);
	assert(sentinel == nil);
	script:signal("s1");
	assert(sentinel);
end);

crystal.test.add("Cross script join keeps execution context", function()
	local t0;
	local scriptA = Script:new(function(self)
			t0 = self:thread(function(self)
					self:waitFor("s0");
				end);
			self:waitFor("s1");
		end);

	local sentinel;
	local scriptB = Script:new(function(self)
			self:join(t0);
			self:waitFor("s2");
			sentinel = true;
		end);

	scriptA:update(0);
	scriptB:update(0);
	assert(sentinel == nil);
	scriptA:signal("s0");
	assert(sentinel == nil);
	scriptB:signal("s2");
	assert(sentinel);
end);

crystal.test.add("End child threads after thread ends", function()
	local a = 0;
	local script = Script:new(function(self)
			self:thread(function()
				self:waitFrame();
				a = 1;
			end);
		end);
	script:update(0);
	assert(a == 0);
	script:update(0);
	assert(a == 0);
end);

crystal.test.add("End grand-child threads after thread ends", function()
	local a = 0;
	local script = Script:new(function(self)
			self:thread(function()
				self:thread(function()
					self:waitFrame();
					a = 1;
				end);
			end);
		end);
	script:update(0);
	assert(a == 0);
	script:update(0);
	assert(a == 0);
end);

crystal.test.add("Signal not propagated to thread it makes appear", function()
	local a = 0;
	local script = Script:new(function(self)
			self:waitFor("signal");
			a = 1;
			self:thread(function()
				self:waitFor("signal");
				a = 2;
			end);
		end);
	script:update(0);
	assert(a == 0);
	script:signal("signal");
	assert(a == 1);
end);

crystal.test.add("Cross-script threading", function()
	local a = 0;

	local scriptA = Script:new();
	scriptA.b = 1;

	local scriptB = Script:new(function(self)
			scriptA:addThreadAndRun(function(self)
				local script = self:getScript();
				assert(script == scriptA);
				a = script.b;
			end);
		end);

	scriptB:update(0);
	assert(a == 1);
end);

crystal.test.add("Pump new thread only once", function()
	local a = 0;
	local script = Script:new(function(self)
			self:thread(function(self)
				a = 1;
				self:waitFrame();
				a = 2;
			end);
		end);

	script:update(0);
	assert(a == 1);
end);

crystal.test.add("Successive waits not treated as waitForAny", function()
	local sentinel = false;
	local script = Script:new(function(self)
			local v1 = self:waitFor("s1");
			assert(v1 == 1);
			local v2 = self:waitFor("s2");
			assert(v2 == 2);
			local v3 = self:waitFor("s3");
			assert(v3 == 3);
			sentinel = true;
		end);

	script:update(0);
	script:signal("s1", 1);
	script:signal("s2", 2);
	script:signal("s3", 3);
	assert(sentinel);
end);

crystal.test.add("Scope cleanup functions run after thread finishes", function()
	local sentinel = false;
	local script = Script:new(function(self)
			self:scope(function()
				sentinel = true
			end);
			self:waitFor("s1");
		end);

	script:update(0);
	assert(not sentinel);
	script:signal("s1");
	assert(sentinel);
end);

crystal.test.add("Scope cleanup functions run after thread is stopped", function()
	local sentinel = false;
	local script = Script:new();
	local t = script:addThreadAndRun(function(self)
			self:scope(function()
				sentinel = true
			end);
			self:waitFor("s1");
		end);

	assert(not sentinel);
	t:stop();
	assert(sentinel);
end);

crystal.test.add("Scope cleanup functions from child threads also run", function()
	local sentinel = false;
	local script = Script:new(function(self)
			self:endOn("s1");
			self:thread(function(self)
				self:scope(function()
					sentinel = true
				end);
				self:hang();
			end);
			self:hang();
		end);

	script:update(0);
	assert(not sentinel);
	script:signal("s1");
	assert(sentinel);
end);

crystal.test.add("Script can be stopped", function()
	local sentinel = 0;

	local script = Script:new();
	script:addThread(function(self)
		while true do
			sentinel = sentinel + 1;
			self:waitFrame();
		end
	end);
	script:addThread(function(self)
		while true do
			sentinel = sentinel + 10;
			self:waitFrame();
		end
	end);

	assert(sentinel == 0);
	script:update(0);
	assert(sentinel == 11);

	script:stopAllThreads();
	script:update(0);
	script:update(0);
	assert(sentinel == 11);
end);

crystal.test.add("Threads can be added after stopping", function()
	local script1 = Script:new();
	local thread = script1:addThreadAndRun(function(self)
			self:hang();
		end);

	local sentinel = false;
	local script2 = Script:new();
	script2:addThreadAndRun(function(self)
		self:join(thread);
		script1:addThreadAndRun(function()
			sentinel = true;
		end);
	end);

	assert(not sentinel);
	script1:stopAllThreads();
	assert(sentinel);
end);

crystal.test.add("Recursive stops don't re-trigger join", function()
	local sentinel = 0;

	local scriptA = Script:new();
	local threadA = scriptA:addThread(function(self)
			self:hang();
		end);

	local scriptB = Script:new();
	scriptB:addThread(function(self)
		self:join(threadA);
		sentinel = sentinel + 1;
		scriptA:stopAllThreads();
	end);

	assert(sentinel == 0);
	scriptA:update(0);
	scriptB:update(0);
	assert(sentinel == 0);
	scriptA:stopAllThreads();
	assert(sentinel == 1);
end);

crystal.test.add("Thread can stop itself", function()
	local sentinel = 0;

	local script = Script:new();
	script:addThreadAndRun(function(self)
		sentinel = 1;
		self:stopAllThreads();
		sentinel = 2;
	end);

	assert(sentinel == 1)
end);

crystal.test.add("Thread can stop its own script", function()
	local sentinel = 0;

	local script = Script:new();
	script:addThreadAndRun(function(self)
		sentinel = 1;
		script:stopAllThreads();
		sentinel = 2;
	end);

	assert(sentinel == 1)
end);

crystal.test.add("Cross-script stop using addThreadAndRun", function()
	local sentinel = 0;

	local scriptA = Script:new();
	local scriptB = Script:new();
	scriptA:addThreadAndRun(function(self)
		sentinel = 1;
		scriptB:addThreadAndRun(function(self)
			scriptA:stopAllThreads();
		end);
		sentinel = 2;
	end);

	scriptA:update(0);
	assert(sentinel == 1)
end);

crystal.test.add("Cross-script stop using a signal", function()
	local sentinel = 0;

	local scriptA = Script:new();
	local scriptB = Script:new();
	scriptA:addThreadAndRun(function(self)
		sentinel = sentinel + 1;
		self:waitFor("signal");
		scriptB:stopAllThreads();
	end);
	scriptB:addThreadAndRun(function(self)
		scriptA:signal("signal");
		sentinel = sentinel + 10;
	end);

	scriptA:update(0);
	assert(sentinel == 1)
end);

--#endregion

return Script;
