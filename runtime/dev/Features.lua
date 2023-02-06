local TableUtils = require("utils/TableUtils");

local Features = {};

local release = love.filesystem.isFused();
Features.tests = TableUtils.contains(arg, "/test");
Features.gfxTests = TableUtils.contains(arg, "/test-gfx");
Features.codeCoverage = TableUtils.contains(arg, "/coverage");
Features.audioOutput = not Features.tests;
Features.display = Features.gfxTests or not Features.tests;
Features.logging = not release;
Features.cli = not release;
Features.fpsCounter = not release;
Features.debugDraw = not release and Features.display;
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
