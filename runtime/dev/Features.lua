local hasFlag = function(value)
	for k, v in pairs(arg) do
		if v == value then
			return true;
		end
	end
	return false;
end

local Features = {};

local release = love.filesystem.isFused();
Features.tests = hasFlag("/test");
Features.codeCoverage = hasFlag("/coverage");
Features.cli = not release;
Features.fpsCounter = not release;
Features.debugDraw = not release;
Features.liveTune = not release;
Features.slowAssertions = not release;
Features.constants = not release;

local noop = function()
end

local stubMetaTable = {
	__newindex = function(t, k, v)
		if type(v) == "function" then
			rawset(t, k, noop);
		end
	end,
};

Features.stub = function(t)
	setmetatable(t, stubMetaTable);
end

return Features;
