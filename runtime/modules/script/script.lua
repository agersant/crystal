local Thread = require("modules/script/thread");
local TableUtils = require("utils/TableUtils");

---@class Script
---@field private _time number
---@field private dt number
---@field private threads { [Thread]: boolean }
---@field private blocked_threads { [Thread]: { [string | Thread]: boolean } }
---@field private blockers { [string | Thread]: { [Thread]: boolean } }
---@field private endable_threads { [Thread]: { [string]: boolean } }
---@field private ending_signals { [string]: { [Thread]: boolean } }
local Script = Class("Script");

---@type Thread[]
local running_threads = {}; -- shared between all Script instances
local health_check = function()
	local running_thread = running_threads[#running_threads];
	if running_thread and running_thread:ended() then
		running_thread:abort();
	end
end

---@param thread Thread
---@param resume_args any[]
local pump_thread;
pump_thread = function(thread, resume_args)
	assert(not thread:ended())
	local self = thread:script();
	local thread_coroutine = thread:coroutine();
	local status = coroutine.status(thread_coroutine);
	assert(status ~= "running");
	local results;
	if status == "suspended" and not self.blocked_threads[thread] then
		table.insert(running_threads, thread);
		if resume_args ~= nil then
			assert(type(resume_args) == "table");
			results = { coroutine.resume(thread_coroutine, resume_args) };
		else
			results = { coroutine.resume(thread_coroutine, thread) };
		end
		table.remove(running_threads);
		local success = results[1];
		if not success then
			local error_text = results[2];
			crystal.log.error(error_text);
			crystal.log.error(debug.traceback(thread_coroutine));
		else
			local instruction = results[2];
			if instruction == "fork" then
				local new_thread = results[3];
				assert(new_thread:is_instance_of(Thread));
				self.threads[new_thread] = true;
				pump_thread(new_thread);
				if not thread:ended() then
					pump_thread(thread, new_thread);
				end
			elseif instruction == "wait_for_signals" then
				local signals = results[3];
				self:block_thread_on_signals(thread, signals);
			elseif instruction == "stop_on_signal" then
				local signal = results[3];
				self:end_thread_on_signal(thread, signal);
				pump_thread(thread);
			elseif instruction == "join" then
				local threads = results[3];
				self:block_thread_on_threads(thread, threads);
			elseif instruction == "hang" then
				assert(not self.blocked_threads[thread]);
				self.blocked_threads[thread] = {};
			elseif instruction == "abort" then
				assert(thread:ended());
			end
		end
	end

	status = coroutine.status(thread_coroutine);
	if status == "dead" and not thread:ended() then
		thread:set_output(results);
		self:end_thread(thread);
	end
end

---@param startup_function fun(self: Thread): any
Script.init = function(self, startup_function)
	self.dt = 0;
	self._time = 0;
	self.threads = {};
	self.blocked_threads = {};
	self.blockers = {};
	self.blocking_threads = {};
	self.endable_threads = {};
	self.ending_signals = {};
	if type(startup_function) == "function" then
		self:add_thread(startup_function);
	end
end

---@param dt number
Script.update = function(self, dt)
	self.dt = dt;
	self._time = self._time + dt;
	local threads = TableUtils.shallowCopy(self.threads);
	for thread in pairs(threads) do
		if not thread:ended() then
			pump_thread(thread);
		end
	end
end

---@param thread Thread
Script.stop_thread = function(self, thread)
	self:end_thread(thread);
	health_check();
end

Script.stop_all_threads = function(self)
	local threads = TableUtils.shallowCopy(self.threads);
	for thread in pairs(threads) do
		thread:mark_as_ended();
	end
	for thread in pairs(threads) do
		self:end_thread(thread);
	end
	health_check();
end

---@return number
Script.time = function(self)
	return self._time;
end

---@return number
Script.delta_time = function(self)
	return self.dt;
end

---@param function_to_thread fun(self: Thread): any
Script.add_thread = function(self, function_to_thread)
	local thread = Thread:new(self, nil, function_to_thread);
	self.threads[thread] = true;
	return thread;
end

---@param function_to_thread fun(self: Thread): any
Script.run_thread = function(self, function_to_thread)
	local thread = self:add_thread(function_to_thread);
	pump_thread(thread);
	health_check();
	return thread;
end

---@param signal string
---@param ... any
Script.signal = function(self, signal, ...)
	if self.ending_signals[signal] then
		for thread in pairs(self.ending_signals[signal]) do
			if not thread:ended() then
				self:end_thread(thread);
			end
		end
	end
	if self.blockers[signal] then
		local blocked_threads = TableUtils.shallowCopy(self.blockers[signal]);
		for thread in pairs(blocked_threads) do
			local resume_args = { ... };
			if TableUtils.countKeys(self.blocked_threads[thread]) > 1 then
				table.insert(resume_args, 1, signal);
			end
			self:unblock_thread(thread, resume_args);
		end
	end
	health_check();
end

---@private
Script.block_thread_on_signals = function(self, thread, signals)
	assert(self == thread:script());
	assert(not thread:ended());
	for _, signal in ipairs(signals) do
		assert(type(signal) == "string");

		if not self.blocked_threads[thread] then
			self.blocked_threads[thread] = {};
		end
		self.blocked_threads[thread][signal] = true;

		if not self.blockers[signal] then
			self.blockers[signal] = {};
		end
		self.blockers[signal][thread] = true;
	end
end

---@private
Script.block_thread_on_threads = function(self, thread, threads_to_join)
	assert(self == thread:script());
	assert(#threads_to_join > 0);
	assert(not thread:ended());
	for _, other_thread in ipairs(threads_to_join) do
		if other_thread:ended() then
			pump_thread(thread, other_thread:output());
			return;
		end
	end
	if not self.blocked_threads[thread] then
		self.blocked_threads[thread] = {};
	end
	for _, other_thread in ipairs(threads_to_join) do
		if not other_thread:ended() then
			local blocking_script = other_thread:script();
			if not blocking_script.blockers[other_thread] then
				blocking_script.blockers[other_thread] = {};
			end
			blocking_script.blockers[other_thread][thread] = true;
			self.blocked_threads[thread][other_thread] = true;
		end
	end
end

---@private
Script.unblock_thread = function(self, thread, resume_args)
	assert(self == thread:script());
	assert(self.blocked_threads[thread]);
	assert(not thread:ended());
	for blocker in pairs(self.blocked_threads[thread]) do
		if type(blocker) == "string" then
			self.blockers[blocker][thread] = nil;
		else
			blocker:script().blockers[blocker][thread] = nil;
		end
	end
	self.blocked_threads[thread] = nil;
	pump_thread(thread, resume_args);
end

---@private
Script.end_thread_on_signal = function(self, thread, signal)
	assert(self == thread:script());
	assert(type(signal) == "string");
	assert(not thread:ended());
	if not self.ending_signals[signal] then
		self.ending_signals[signal] = {};
	end
	self.ending_signals[signal][thread] = true;
	if not self.endable_threads[thread] then
		self.endable_threads[thread] = {};
	end
	self.endable_threads[thread][signal] = true;
end

---@private
Script.end_thread = function(self, thread)
	assert(self == thread:script());
	if not thread:ended() then
		thread:mark_as_ended();
	end
	for child_thread in pairs(thread:children()) do
		self:end_thread(child_thread);
	end
	thread:run_deferred_functions();
	local threads_to_unblock;
	if self.blockers[thread] then
		threads_to_unblock = TableUtils.shallowCopy(self.blockers[thread]);
	end
	self:cleanup_thread(thread);
	if threads_to_unblock then
		for blocked_thread in pairs(threads_to_unblock) do
			if not blocked_thread:ended() then
				blocked_thread:script():unblock_thread(blocked_thread, thread:output() or { false });
			end
		end
	end
end

---@private
Script.cleanup_thread = function(self, thread)
	-- Remove this thread from lists of threads to end when signals happen
	if self.endable_threads[thread] then
		for signal in pairs(self.endable_threads[thread]) do
			self.ending_signals[signal][thread] = nil;
		end
	end
	-- Remove this thread from lists of threads to unblock when signals happen or other threads end
	if self.blocked_threads[thread] then
		for blocker in pairs(self.blocked_threads[thread]) do
			if type(blocker) == "string" then
				self.blockers[blocker][thread] = nil;
			else
				blocker:script().blockers[blocker][thread] = nil;
			end
		end
	end
	-- Remove this thread from list of things that can unblock other threads
	if self.blockers[thread] then
		for blocked in pairs(self.blockers[thread]) do
			blocked:script().blocked_threads[blocked][thread] = nil;
		end
	end
	self.blocked_threads[thread] = nil;
	self.endable_threads[thread] = nil;
	self.blockers[thread] = nil;
	self.threads[thread] = nil;
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
		self:wait_frame();
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
		self:wait_for("testSignal");
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
		self:wait_for("test1");
		a = 1;
		self:wait_for("test2");
		a = 2;
		self:wait_frame();
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
		self:wait_for_any({ "testSignal", "gruik" });
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
			self:wait_frame();
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
			self:wait_frame();
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
	local t0 = script:run_thread(function()
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
		a = self:wait_for("testSignal");
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
		s, a = self:wait_for_any({ "testSignal", "gruik" });
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
			self:wait_for("s0");
			sentinel = false;
		end);
		local t1 = self:thread(function(self)
			self:wait_for("s1");
			t0:stop();
		end);
		self:hang();
	end);
	script:update(0);
	script:signal("s1");
	script:signal("s0");
	assert(sentinel);
end);

crystal.test.add("Stop on", function()
	local a = 0;
	local script = Script:new(function(self)
		self:stop_on("end");
		self:wait_frame();
		a = 1;
	end);
	script:update(0);
	assert(a == 0);
	script:signal("end");
	script:update(0);
	assert(a == 0);
end);

crystal.test.add("Unblock after stop on", function()
	local a = 0;
	local script = Script:new(function(self)
		self:stop_on("end");
		self:wait_for("signal");
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
	local t1 = script:run_thread(function(self)
		self:wait_for("s1");
		self:wait_for("s2");
	end);
	local t2 = script:run_thread(function(self)
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
	local t1 = script:run_thread(function(self)
		self:wait_for("s1");
		self:wait_for("s2");
	end);
	local t2 = script:run_thread(function(self)
		self:wait_for("s3");
	end);
	local t3 = script:run_thread(function(self)
		self:join_any({ t1, t2 });
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
	local t1 = script:run_thread(function(self)
		self:wait_for("s1");
	end);
	local t2 = script:run_thread(function(self)
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
	local t1 = script:run_thread(function(self)
		self:wait_for("s1");
	end);
	local t2 = script:run_thread(function(self)
		completed = self:join(t1);
	end);
	local t3 = script:run_thread(function(self)
		self:wait_for("s2");
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
	local t1 = script:run_thread(function(self)
		self:wait_for("s1");
		return 10;
	end);
	local t2 = script:run_thread(function(self)
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
	local t0 = script:run_thread(function(self)
		local t01 = self:thread(function(self)
			self:hang();
		end);
		self:thread(function(self)
			self:join(t01);
			sentinel = false;
		end);
		self:hang();
	end);
	local t1 = script:run_thread(function(self)
		self:wait_for("s1");
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
	local t0 = script:run_thread(function(self)
	end);
	local t1 = script:run_thread(function(self)
	end);
	local t2 = script:run_thread(function(self)
		self:wait_for("s1");
		self:join(t0);
		self:join(t1);
		sentinel = 1;
		self:wait_frame();
		sentinel = 2;
	end);

	script:update(0);
	assert(sentinel == nil);
	script:signal("s1");
	assert(sentinel == 1);
	script:update(0);
	assert(sentinel == 2);
end);

crystal.test.add("Cross script join keeps execution context", function()
	local t0;
	local scriptA = Script:new(function(self)
		t0 = self:thread(function(self)
			self:wait_for("s0");
		end);
		self:wait_for("s1");
	end);

	local sentinel;
	local scriptB = Script:new(function(self)
		self:join(t0);
		self:wait_for("s2");
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
			self:wait_frame();
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
				self:wait_frame();
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
		self:wait_for("signal");
		a = 1;
		self:thread(function()
			self:wait_for("signal");
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
		scriptA:run_thread(function(self)
			local script = self:script();
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
			self:wait_frame();
			a = 2;
		end);
	end);

	script:update(0);
	assert(a == 1);
end);

crystal.test.add("Successive waits not treated as wait_for_any", function()
	local sentinel = false;
	local script = Script:new(function(self)
		local v1 = self:wait_for("s1");
		assert(v1 == 1);
		local v2 = self:wait_for("s2");
		assert(v2 == 2);
		local v3 = self:wait_for("s3");
		assert(v3 == 3);
		sentinel = true;
	end);

	script:update(0);
	script:signal("s1", 1);
	script:signal("s2", 2);
	script:signal("s3", 3);
	assert(sentinel);
end);

crystal.test.add("Deferred functions run after thread finishes", function()
	local sentinel = false;
	local script = Script:new(function(self)
		self:defer(function()
			sentinel = true
		end);
		self:wait_for("s1");
	end);

	script:update(0);
	assert(not sentinel);
	script:signal("s1");
	assert(sentinel);
end);

crystal.test.add("Deferred functions run when thread is stopped", function()
	local sentinel = false;
	local script = Script:new();
	local t = script:run_thread(function(self)
		self:defer(function()
			sentinel = true
		end);
		self:wait_for("s1");
	end);

	assert(not sentinel);
	t:stop();
	assert(sentinel);
end);

crystal.test.add("Deferred functions from child threads also run", function()
	local sentinel = false;
	local script = Script:new(function(self)
		self:stop_on("s1");
		self:thread(function(self)
			self:defer(function()
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
	script:add_thread(function(self)
		while true do
			sentinel = sentinel + 1;
			self:wait_frame();
		end
	end);
	script:add_thread(function(self)
		while true do
			sentinel = sentinel + 10;
			self:wait_frame();
		end
	end);

	assert(sentinel == 0);
	script:update(0);
	assert(sentinel == 11);

	script:stop_all_threads();
	script:update(0);
	script:update(0);
	assert(sentinel == 11);
end);

crystal.test.add("Threads can be added after stopping", function()
	local script1 = Script:new();
	local thread = script1:run_thread(function(self)
		self:hang();
	end);

	local sentinel = false;
	local script2 = Script:new();
	script2:run_thread(function(self)
		self:join(thread);
		script1:run_thread(function()
			sentinel = true;
		end);
	end);

	assert(not sentinel);
	script1:stop_all_threads();
	assert(sentinel);
end);

crystal.test.add("Recursive stops don't re-trigger join", function()
	local sentinel = 0;

	local scriptA = Script:new();
	local threadA = scriptA:add_thread(function(self)
		self:hang();
	end);

	local scriptB = Script:new();
	scriptB:add_thread(function(self)
		self:join(threadA);
		sentinel = sentinel + 1;
		scriptA:stop_all_threads();
	end);

	assert(sentinel == 0);
	scriptA:update(0);
	scriptB:update(0);
	assert(sentinel == 0);
	scriptA:stop_all_threads();
	assert(sentinel == 1);
end);

crystal.test.add("Thread can stop itself", function()
	local sentinel = 0;

	local script = Script:new();
	script:run_thread(function(self)
		sentinel = 1;
		self:stop_all_threads();
		sentinel = 2;
	end);

	assert(sentinel == 1)
end);

crystal.test.add("Thread can stop its own script", function()
	local sentinel = 0;

	local script = Script:new();
	script:run_thread(function(self)
		sentinel = 1;
		script:stop_all_threads();
		sentinel = 2;
	end);

	assert(sentinel == 1)
end);

crystal.test.add("Cross-script stop using run_thread", function()
	local sentinel = 0;

	local scriptA = Script:new();
	local scriptB = Script:new();
	scriptA:run_thread(function(self)
		sentinel = 1;
		scriptB:run_thread(function(self)
			scriptA:stop_all_threads();
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
	scriptA:run_thread(function(self)
		sentinel = sentinel + 1;
		self:wait_for("signal");
		scriptB:stop_all_threads();
	end);
	scriptB:run_thread(function(self)
		scriptA:signal("signal");
		sentinel = sentinel + 10;
	end);

	scriptA:update(0);
	assert(sentinel == 1)
end);

crystal.test.add("Child thread can immediately end parent", function()
	local sentinel = 0;

	local script = Script:new();
	script:run_thread(function(self)
		self:stop_on("s1");
		self:thread(function()
			sentinel = 1;
			self:signal("s1");
			sentinel = 2;
		end);
	end);

	script:update(0);
	assert(sentinel == 1)
	script:update(0);
	assert(sentinel == 1)
end);

crystal.test.add("Stopping parent does not cause siblings to unblock each other", function()
	local sentinel = 0;

	local script = Script:new();
	local parent = script:run_thread(function(self)
		local t0, t1;
		t0 = self:thread(function(self)
			self:wait_for("ready");
			sentinel = 1;
			self:join(t1);
			sentinel = 2;
		end);
		t1 = self:thread(function(self)
			self:wait_for("ready");
			sentinel = 1;
			self:join(t0);
			sentinel = 2;
		end);
		self:hang();
	end);

	script:signal("ready");
	parent:stop();
	assert(sentinel == 1);
end);

crystal.test.add("Stopping all threads, in any order, does not cause siblings to unblock each other", function()
	local sentinel = 0;

	local script = Script:new();
	local parent = script:run_thread(function(self)
		local t0, t1;
		t0 = self:thread(function(self)
			self:wait_for("ready");
			sentinel = 1;
			self:join(t1);
			sentinel = 2;
		end);
		t1 = self:thread(function(self)
			self:wait_for("ready");
			sentinel = 1;
			self:join(t0);
			sentinel = 2;
		end);
		self:hang();
	end);

	script:signal("ready");
	script:stop_all_threads();
	assert(sentinel == 1);
end);

crystal.test.add("Cannot block a thread that isn't running", function()
	local script = Script:new();
	local t0 = script:run_thread(function(self)
		self:hang();
	end);
	local t1 = script:add_thread(function()
	end);

	local can_wait = true;
	script:run_thread(function(self)
		can_wait = pcall(function()
			t0:wait_for("s0");
		end);
	end);
	assert(not can_wait);

	local can_join = true;
	script:run_thread(function(self)
		can_join = pcall(function()
			t0:join(t1);
		end);
	end);
	assert(not can_join);

	local can_hang = true;
	script:run_thread(function(self)
		can_hang = pcall(function()
			t0:hang();
		end);
	end);
	assert(not can_hang);
end);


crystal.test.add("Double thread stop does not re-run deferred functions", function()
	local script = Script:new();
	local sentinel = 0;
	local t0 = script:run_thread(function(self)
		self:defer(function()
			sentinel = sentinel + 1;
		end);
		self:hang();
	end);
	script:stop_thread(t0);
	script:stop_thread(t0);
	assert(sentinel == 1);
end);

--#endregion

return Script;
