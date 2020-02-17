require("engine/utils/OOP");
local DamageNumbers = require("arpg/field/hud/damage/DamageNumbers");
local DialogBox = require("arpg/field/hud/dialog/DialogBox");
local Widget = require("engine/ui/Widget");

local HUD = Class("HUD", Widget);

HUD.init = function(self, field)
	assert(field);
	HUD.super.init(self);
	self._field = field;
	self._damageNumbers = DamageNumbers:new(field);
	self._dialog = DialogBox:new(field);
	self:addChild(self._damageNumbers);
	self:addChild(self._dialog);
end

return HUD;
