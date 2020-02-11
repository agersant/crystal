require("engine/utils/OOP");
local Module = require("engine/Module");
local Content = require("engine/resources/Content");

local ARPG = Class("ARPG", Module);

ARPG.init = function(self)
	ARPG.super.init(self);
	self.classes.MapScene = require("arpg/field/Field");
	self.classes.SaveData = require("arpg/persistence/SaveData");
	self.testFiles = {
		"arpg/combat/ai/TestTargetSelector",
		"arpg/combat/TestCombatLogic",
		"arpg/party/TestParty",
		"arpg/party/TestPartyMember",
	};
	Content:requireAll("content");
end

return ARPG;
