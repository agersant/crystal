require("engine/utils/OOP");
local Widget = require("engine/ui/Widget");
local Text = require("engine/ui/core/Text");

local TitleScreen = Class("TitleScreen", Widget);

-- PUBLIC API

TitleScreen.init = function(self)
	TitleScreen.super.init(self);
	local text = Text:new("fat", 16);
	text:setText("Project Crystal");
	self:addChild(text);
end

return TitleScreen;
