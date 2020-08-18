require("engine/utils/OOP");
local Module = require("engine/Module");
local Content = require("engine/resources/Content");

local ARPG = Class("ARPG", Module);

ARPG.init = function(self)
	ARPG.super.init(self);
	self.classes.MapScene = require("arpg/field/Field");
	self.classes.SaveData = require("arpg/persistence/SaveData");
	self.mapDirectory = "arpg/assets/map";
	self.testFiles = {
		"arpg/field/combat/ai/TestTargetSelector",
		"arpg/field/combat/TestCombatData",
		"arpg/persistence/party/TestPartyData",
		"arpg/persistence/party/TestPartyMemberData",
		"arpg/field/hud/dialog/TestDialog",
	};
	self.fonts = {
		small = "arpg/assets/font/16bfZX.ttf",
		body = "arpg/assets/font/karen2black.ttf",
		fat = "arpg/assets/font/karenfat.ttf",
	};
	Content:requireAll("content");
end

return ARPG;
