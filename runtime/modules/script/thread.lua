local Alias = require("utils/Alias");
local MathUtils = require("utils/MathUtils");
local TableUtils = require("utils/TableUtils");

---@class Thread
---@field private _coroutine coroutine
---@field private _script Script
---@field private _children { [Thread]: boolean }
---@field private _deferred_functions fun()[]
local Thread = Class("Thread");

Thread.init = function(self, script, parent, function_to_thread)
	assert(type(function_to_thread) == "function");
	self._coroutine = coroutine.create(function_to_thread);
	self._script = script;
	self._children = {};
	self._deferred_functions = {};
	if parent then
		parent._children[self] = true;
	end
	Alias:add(self, script); -- TODO remove this
end

---@return Script
Thread.script = function(self)
	return self._script;
end

---@return coroutine
Thread.coroutine = function(self)
	return self._coroutine;
end

---@return boolean
Thread.is_dead = function(self)
	return coroutine.status(self._coroutine) == "dead" or self._ended;
end

---@param output any
Thread.set_output = function(self, output)
	self._output = output;
end

---@return any
Thread.output = function(self, output)
	return self._output;
end

Thread.mark_as_ended = function(self)
	self._ended = true;
	for child in pairs(self._children) do
		child:mark_as_ended();
	end
end

Thread.ended = function(self)
	return self._ended;
end

---@return { [Thread]: true }
Thread.children = function(self)
	return self._children;
end

Thread.run_deferred_functions = function(self)
	for i = #self._deferred_functions, 1, -1 do
		self._deferred_functions[i]();
	end
end

Thread.wait_frame = function(self)
	coroutine.yield("waitFrame");
end

Thread.wait = function(self, seconds)
	local endTime = self._script:time() + seconds;
	while self._script:time() < endTime do
		coroutine.yield("wait");
	end
end

---@return Thread
Thread.thread = function(self, function_to_thread)
	assert(not self:is_dead());
	assert(type(function_to_thread) == "function");
	local new_thread = Thread:new(self._script, self, function_to_thread)
	return coroutine.yield("fork", new_thread);
end

---@return any
Thread.wait_for = function(self, signal)
	assert(not self:is_dead());
	assert(type(signal) == "string");
	return self:wait_for_any({ signal });
end

---@return any
Thread.wait_for_any = function(self, signals)
	assert(not self:is_dead());
	assert(type(signals) == "table");
	local returns = coroutine.yield("waitForSignals", signals);
	return unpack(returns);
end

Thread.end_on = function(self, signal)
	assert(not self:is_dead());
	assert(type(signal) == "string");
	coroutine.yield("endOnSignal", signal);
end

---@return any
Thread.join = function(self, thread)
	assert(not self:is_dead());
	assert(thread);
	return self:join_any({ thread });
end

---@return any
Thread.join_any = function(self, threads)
	assert(not self:is_dead());
	local returns = coroutine.yield("join", threads);
	return unpack(returns);
end

Thread.hang = function(self)
	assert(not self:is_dead());
	coroutine.yield("hang");
end

Thread.stop = function(self)
	assert(not self:is_dead());
	self._script:stop_thread(self, false);
end

Thread.abort = function(self)
	assert(self:ended());
	if coroutine.running() == self._coroutine then
		coroutine.yield("abort");
	end
end

Thread.defer = function(self, deferred_function)
	assert(not self:is_dead());
	assert(type(deferred_function) == "function");
	table.insert(self._deferred_functions, deferred_function);
end

---@return Thread
Thread.tween = function(self, from, to, duration, easing, callback, arg)
	return self:thread(function(self)
		self:wait_tween(from, to, duration, easing, callback, arg);
	end);
end

Thread.wait_tween = function(self, from, to, duration, easing, callback, arg)
	assert(duration >= 0);
	if duration == 0 then
		if arg then
			callback(arg, to);
		else
			callback(to);
		end
		return;
	end
	local startTime = self._script:time();
	while self._script:time() <= startTime + duration do
		local t = (self._script:time() - startTime) / duration;
		local t = MathUtils.ease(t, easing);
		local currentValue = from + t * (to - from);
		if arg then
			callback(arg, currentValue);
		else
			callback(currentValue);
		end
		self:wait_frame();
	end
end

return Thread;
