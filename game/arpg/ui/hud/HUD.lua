require("engine/utils/OOP");
local DamageNumbers = require("arpg/ui/hud/damage/DamageNumbers");
local Dialog = require("arpg/ui/hud/Dialog");
local Widget = require("engine/ui/Widget");

local HUD = Class("HUD", Widget);

HUD.init = function(self, field)
	assert(field);
	HUD.super.init(self);
	self._field = field;
	self._damageNumbers = DamageNumbers:new(self);
	self._dialog = Dialog:new();
	self:addChild(self._damageNumbers);
	self:addChild(self._dialog);
end

HUD.getField = function(self)
	return self._field;
end

HUD.getDialog = function(self)
	return self._dialog;
end

return HUD;
