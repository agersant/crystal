local Script = require("script/Script");

local tests = {};

tests[#tests + 1] = { name = "Script runs" };
tests[#tests].body = function()
	local a = 0;
	local script = Script:new(function(self)
		a = a + 1;
	end);
	assert(a == 0);
	script:update(0);
	assert(a == 1);
	script:update(0);
	assert(a == 1);
end

tests[#tests + 1] = { name = "Wait frame" };
tests[#tests].body = function()
	local a = 0;
	local script = Script:new(function(self)
		self:waitFrame();
		a = a + 1;
	end);
	script:update(0);
	assert(a == 0);
	script:update(0);
	assert(a == 1);
end

tests[#tests + 1] = { name = "Wait duration" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Wait for" };
tests[#tests].body = function()
	local a = 0;
	local script = Script:new(function(self)
		self:waitFor("testSignal");
		a = a + 1;
	end);
	script:update(0);
	assert(a == 0);
	script:signal("testSignal");
	assert(a == 1);
end

tests[#tests + 1] = { name = "Successive waits" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Wait for any" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Start thread" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Stop thread" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Cannot start thread from stopped thread" };
tests[#tests].body = function()
	local script = Script:new();
	local t0 = script:addThreadAndRun(function()
	end);
	local success = pcall(function()
		t0:thread(function()
		end);
	end);
	assert(not success);

end

tests[#tests + 1] = { name = "Signal additional data" };
tests[#tests].body = function()
	local a = 0;
	local script = Script:new(function(self)
		a = self:waitFor("testSignal");
	end);
	assert(a == 0);
	script:update(0);
	assert(a == 0);
	script:signal("testSignal", 1);
	assert(a == 1);
end

tests[#tests + 1] = { name = "Multiple signals additional data" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Signal doesn't wake dead threads" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "End on" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Unblock after end on" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Wait for join" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Join any" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Join returns true when joined thread completed" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Join returns false when joined thread was stopped" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Join returns thread output" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Join doesn't unblock when parent thread is in the process of stopping" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Joining dead threads is no-op" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Cross script join keeps execution context" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "End child threads after thread ends" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "End grand-child threads after thread ends" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Signal not propagated to thread it makes appear" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Cross-script threading" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Pump new thread only once" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Successive waits not treated as waitForAny" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Scope cleanup functions run after thread finishes" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Scope cleanup functions run after thread is stopped" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Scope cleanup functions from child threads also run" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Script can be stopped" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Threads can be added after stopping" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Recursive stops don't re-trigger join" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Thread can stop itself" };
tests[#tests].body = function()
	local sentinel = 0;

	local script = Script:new();
	script:addThreadAndRun(function(self)
		sentinel = 1;
		self:stopAllThreads();
		sentinel = 2;
	end);

	assert(sentinel == 1)
end

tests[#tests + 1] = { name = "Thread can stop its own script" };
tests[#tests].body = function()
	local sentinel = 0;

	local script = Script:new();
	script:addThreadAndRun(function(self)
		sentinel = 1;
		script:stopAllThreads();
		sentinel = 2;
	end);

	assert(sentinel == 1)
end

tests[#tests + 1] = { name = "Cross-script stop using addThreadAndRun" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Cross-script stop using a signal" };
tests[#tests].body = function()
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
end

return tests;
