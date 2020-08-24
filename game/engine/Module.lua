require("engine/utils/OOP");

local Module = Class("Module");

Module.init = function(self)
	self.classes = {MapScene = require("engine/mapscene/MapScene"), SaveData = require("engine/persistence/BaseSaveData")};
	self.mapDirectory = "engine/assets";
	self.testFiles = {};
	self.fonts = {};
end

-- STATIC

local currentModule;

Module.getCurrent = function(self)
	return currentModule;
end

Module.setCurrent = function(self, module)
	assert(module);
	assert(module:isInstanceOf(Module));
	currentModule = module;
end

return Module;
