require("engine/utils/OOP");
local Module = require("engine/Module");
local Content = require("engine/resources/Content");

local ARPG = Class("ARPG", Module);

ARPG.init = function(self)
	ARPG.super.init(self);
	self.classes.MapScene = require("arpg/field/Field");
	Content:requireAll("content");
end

return ARPG;
