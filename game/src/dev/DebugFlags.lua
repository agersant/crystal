require("src/utils/OOP");

local DebugFlags = Class("DebugFlags");

DebugFlags.init = function(self)
	self.drawNavmesh = false;
	self.drawPhysics = false;
end

local instance = DebugFlags:new();

return instance;
