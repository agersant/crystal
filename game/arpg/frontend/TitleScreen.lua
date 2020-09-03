require("engine/utils/OOP");
local Fonts = require("engine/resources/Fonts");
local HorizontalAlignment = require("engine/ui/bricks/core/HorizontalAlignment");
local VerticalAlignment = require("engine/ui/bricks/core/VerticalAlignment");
local Overlay = require("engine/ui/bricks/elements/Overlay");
local Widget = require("engine/ui/bricks/elements/Widget");
local Text = require("engine/ui/bricks/elements/Text");
local UIScene = require("engine/ui/UIScene");

local TitleScreenWidget = Class("TitleScreenWidget", Widget);
local TitleScreen = Class("TitleScreen", UIScene);

TitleScreenWidget.init = function(self)
	TitleScreenWidget.super.init(self);

	local overlay = Overlay:new();
	self:setRoot(overlay);

	local text = Text:new();
	overlay:addChild(text);
	text:setFont(Fonts:get("fat", 16));
	text:setContent("Project Crystal");
	text:setHorizontalAlignment(HorizontalAlignment.CENTER);
	text:setVerticalAlignment(VerticalAlignment.CENTER);
end

TitleScreen.init = function(self)
	TitleScreen.super.init(self, TitleScreenWidget:new());
end

return TitleScreen;
