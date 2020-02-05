require("engine/utils/OOP");

local Module = Class("Module");

Module.init = function(self)
	self.classes = {MapScene = require("engine/scene/MapScene")};
end

-- STATIC

local currentModule = Module:new();

Module.getCurrent = function(self)
	return currentModule;
end

Module.setCurrent = function(self, module)
	assert(module);
	assert(module:isInstanceOf(Module));
	currentModule = module;
end

return Module;
