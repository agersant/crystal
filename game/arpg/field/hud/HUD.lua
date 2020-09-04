require("engine/utils/OOP");
local DialogBox = require("arpg/field/hud/dialog/DialogBox");
local HorizontalAlignment = require("engine/ui/bricks/core/HorizontalAlignment");
local VerticalAlignment = require("engine/ui/bricks/core/VerticalAlignment");
local Overlay = require("engine/ui/bricks/elements/Overlay");
local Widget = require("engine/ui/bricks/elements/Widget");

local HUD = Class("HUD", Widget);

HUD.init = function(self)
	HUD.super.init(self);

	local overlay = self:setRoot(Overlay:new());

	self._dialogBox = overlay:addChild(DialogBox:new());
	self._dialogBox:setLeftPadding(28);
	self._dialogBox:setRightPadding(28);
	self._dialogBox:setBottomPadding(8);
	self._dialogBox:setHorizontalAlignment(HorizontalAlignment.STRETCH);
	self._dialogBox:setVerticalAlignment(VerticalAlignment.BOTTOM);
end

HUD.getDialogBox = function(self)
	return self._dialogBox;
end

return HUD;
