require("engine/utils/OOP");
local DialogBox = require("arpg/field/hud/dialog/DialogBox");
local Widget = require("engine/ui/Widget");

local HUD = Class("HUD", Widget);

HUD.init = function(self, field)
	assert(field);
	HUD.super.init(self);
	self._field = field;
	self._dialog = DialogBox:new(field); -- TODO decouple from field
	self:addChild(self._dialog);
end

return HUD;
