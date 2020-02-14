local Script = require("engine/script/Script");

local tests = {};

tests[#tests + 1] = {name = "Script runs"};
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

tests[#tests + 1] = {name = "Wait frame"};
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

tests[#tests + 1] = {name = "Wait duration"};
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

tests[#tests + 1] = {name = "Wait for"};
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

tests[#tests + 1] = {name = "Successive waits"};
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

tests[#tests + 1] = {name = "Wait for any"};
tests[#tests].body = function()
	local a = 0;
	local script = Script:new(function(self)
		self:waitForAny({"testSignal", "gruik"});
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

tests[#tests + 1] = {name = "Start thread"};
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

tests[#tests + 1] = {name = "Stop thread"};
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

tests[#tests + 1] = {name = "Signal additional data"};
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

tests[#tests + 1] = {name = "Multiple signals additional data"};
tests[#tests].body = function()
	local a = 0;
	local s = "";
	local script = Script:new(function(self)
		s, a = self:waitForAny({"testSignal", "gruik"});
	end);
	assert(a == 0);
	script:update(0);
	assert(a == 0);
	script:signal("gruik", 1);
	assert(s == "gruik");
	assert(a == 1);
end

tests[#tests + 1] = {name = "Signal doesn't wake dead threads"};
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

tests[#tests + 1] = {name = "End on"};
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

tests[#tests + 1] = {name = "Unblock after end on"};
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

tests[#tests + 1] = {name = "Wait for join"};
tests[#tests].body = function()
	local sentinel = false;
	local script = Script:new(function(self)
		local t1 = self:thread(function(self)
			self:waitFor("s1");
			self:waitFor("s2");
		end);
		local t2 = self:thread(function(self)
			self:join(t1);
			sentinel = true;
		end);
	end);

	script:update(0);
	assert(not sentinel);
	script:signal("s1");
	assert(not sentinel);
	script:signal("s2");
	assert(sentinel);
end

tests[#tests + 1] = {name = "Join any"};
tests[#tests].body = function()
	local sentinel = false;
	local script = Script:new(function(self)
		local t1 = self:thread(function(self)
			self:waitFor("s1");
			self:waitFor("s2");
		end);
		local t2 = self:thread(function(self)
			self:waitFor("s3");
		end);
		local t3 = self:thread(function(self)
			self:joinAny({t1, t2});
			sentinel = true;
		end);
	end);

	script:update(0);
	assert(not sentinel);
	script:signal("s1");
	assert(not sentinel);
	script:signal("s3");
	assert(sentinel);
end

tests[#tests + 1] = {name = "Join returns true when joined thread completed"};
tests[#tests].body = function()
	local completed;
	local script = Script:new(function(self)
		local t1 = self:thread(function(self)
			self:waitFor("s1");
		end);
		local t2 = self:thread(function(self)
			local c = self:join(t1);
			completed = c;
		end);
	end);

	script:update(0);
	assert(completed == nil);
	script:signal("s1");
	assert(completed);
end

tests[#tests + 1] = {name = "Join returns false when joined thread was stopped"};
tests[#tests].body = function()
	local completed;
	local script = Script:new(function(self)
		local t1 = self:thread(function(self)
			self:waitFor("s1");
		end);
		local t2 = self:thread(function(self)
			completed = self:join(t1);
		end);
		local t3 = self:thread(function(self)
			self:waitFor("s2");
			t1:stop();
		end);
	end);

	script:update(0);
	assert(completed == nil);
	script:signal("s2");
	assert(completed == false);
end

tests[#tests + 1] = {name = "Join doesn't unblock when parent thread is in the process of stopping"};
tests[#tests].body = function()
	local sentinel;
	local script = Script:new(function(self)
		local t0 = self:thread(function(self)
			local t01 = self:thread(function(self)
				self:waitFor("s01");
			end);
			local t02 = self:thread(function(self)
				self:join(t01);
				sentinel = false;
			end);
			self:waitFor("s0");
		end);
		local t1 = self:thread(function(self)
			self:waitFor("s1");
			sentinel = true;
			t0:stop();
		end);
	end);

	script:update(0);
	assert(sentinel == nil);
	script:signal("s1");
	assert(sentinel);
end

tests[#tests + 1] = {name = "Joining dead threads is no-op"};
tests[#tests].body = function()
	local sentinel;
	local script = Script:new(function(self)
		local t0 = self:thread(function(self)
		end);
		local t1 = self:thread(function(self)
		end);
		local t2 = self:thread(function(self)
			self:waitFor("s1");
			self:join(t0);
			self:join(t1);
			sentinel = true;
		end);
	end);

	script:update(0);
	assert(sentinel == nil);
	script:signal("s1");
	assert(sentinel);
end

tests[#tests + 1] = {name = "Keep child threads after main thread ends"};
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
	assert(a == 1);
end

tests[#tests + 1] = {name = "End grand-child threads after owner ends"};
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

tests[#tests + 1] = {name = "Signal not propagated to thread it makes appear"};
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

tests[#tests + 1] = {name = "Cross-script threading"};
tests[#tests].body = function()
	local a = 0;

	local scriptA = Script:new(function(self)
	end);
	scriptA.b = 1;

	local scriptB = Script:new(function(self)
		scriptA:thread(function(self)
			assert(self == scriptA);
			a = self.b;
		end);
	end);

	scriptB:update(0);
	assert(a == 1);
end

tests[#tests + 1] = {name = "Pump new thread only once"};
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

tests[#tests + 1] = {name = "Succesive waits not treated as waitForAny"};
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

return tests;
