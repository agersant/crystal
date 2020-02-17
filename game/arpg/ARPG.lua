require("engine/utils/OOP");
local Module = require("engine/Module");
local Content = require("engine/resources/Content");

local ARPG = Class("ARPG", Module);

ARPG.init = function(self)
	ARPG.super.init(self);
	self.classes.MapScene = require("arpg/field/Field");
	self.classes.SaveData = require("arpg/persistence/SaveData");
	self.testFiles = {
		"arpg/field/combat/ai/TestTargetSelector",
		"arpg/field/combat/TestCombatData",
		"arpg/party/TestPartyData",
		"arpg/party/TestPartyMemberData",
		"arpg/field/hud/dialog/TestDialog",
	};
	Content:requireAll("content");
end

return ARPG;
