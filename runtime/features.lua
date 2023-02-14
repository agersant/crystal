local has_flag = function(value)
	for k, v in pairs(arg) do
		if v == value then
			return true;
		end
	end
	return false;
end

local features = {};

local release = love.filesystem.isFused();
features.tests = has_flag("/test");
features.test_coverage = has_flag("/coverage");
features.cli = not release;
features.tools = not release;
features.debug_draw = not release;
features.slow_assertions = not release;
features.writable_constants = not release;

local noop = function()
end

local stub_metatable = {
	__newindex = function(t, k, v)
		if type(v) == "function" then
			rawset(t, k, noop);
		end
	end,
};

features.stub = function(t)
	setmetatable(t, stub_metatable);
end

return features;
