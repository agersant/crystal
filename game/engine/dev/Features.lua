require("engine/utils/OOP");
local TableUtils = require("engine/utils/TableUtils");

local Features = Class("Features");

Features.init = function(self)
	local release = love.filesystem.isFused();
	self.unitTesting = TableUtils.contains(arg, "/test");
	self.codeCoverage = TableUtils.contains(arg, "/coverage");
	self.audioOutput = not self.unitTesting;
	self.display = not self.unitTesting;
	self.logging = not release and not self.unitTesting;
	-- TODO adjustable logging level so warnings and errors appear during unit tests
	self.cli = not release;
	self.fpsCounter = not release;
	self.debugDraw = not release and self.display;
	self.slowAssertions = not release;
end

local doNothing = function()
end;

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

local instance = Features:new();

return instance;
