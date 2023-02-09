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
Features.gameTests = hasFlag("/test");
Features.engineTests = hasFlag("/test-self");
Features.tests = Features.engineTests or Features.gameTests;
Features.codeCoverage = hasFlag("/coverage");
Features.logging = not release;
Features.cli = not release;
Features.fpsCounter = not release;
Features.debugDraw = not release;
Features.liveTune = not release;
Features.slowAssertions = not release;
Features.constants = not release;

local doNothing = function()
end

local stubMetaTable = {
	__newindex = function(t, k, v)
		if type(v) == "function" then
			rawset(t, k, doNothing);
		end
	end,
};

Features.stub = function(t)
	setmetatable(t, stubMetaTable);
end

return Features;
