require("engine/utils/OOP");
local DialogBox = require("arpg/field/hud/dialog/DialogBox");
local Widget = require("engine/ui/Widget");

local HUD = Class("HUD", Widget);

HUD.init = function(self)
	HUD.super.init(self);
	self._dialogBox = self:addChild(DialogBox:new());
end

HUD.getDialogBox = function(self)
	return self._dialogBox;
end

return HUD;
