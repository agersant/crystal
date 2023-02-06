local TableUtils = require("utils/TableUtils");

local Features = {};

local release = love.filesystem.isFused();
Features.unitTesting = TableUtils.contains(arg, "/test-unit");
Features.gfxTesting = TableUtils.contains(arg, "/test-gfx");
Features.testing = Features.unitTesting or Features.gfxTesting;
Features.codeCoverage = TableUtils.contains(arg, "/coverage");
Features.audioOutput = not Features.testing;
Features.display = Features.gfxTesting or not Features.testing;
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
