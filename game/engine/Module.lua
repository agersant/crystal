require("engine/utils/OOP");

local Module = Class("Module");

Module.init = function(self)
	self.classes = {MapScene = require("engine/mapscene/MapScene"), SaveData = require("engine/persistence/BaseSaveData")};
	self.mapDirectory = "engine/assets";
	self.testFiles = {};
	self.fonts = {};
end

return Module;
