local GFXConfig = require("engine/graphics/GFXConfig");

local setZoom = function(zoom)
	GFXConfig:setZoom(zoom);
end

local enableFullscreen = function()
	GFXConfig:setFullscreenEnabled(true);
end

local disableFullscreen = function()
	GFXConfig:setFullscreenEnabled(false);
end

local GFXCommands = {};

GFXCommands.registerCommands = function(self, cli)
	cli:addCommand("setZoom zoom:number", setZoom);
	cli:addCommand("enableFullscreen", enableFullscreen);
	cli:addCommand("disableFullscreen", disableFullscreen);
end

return GFXCommands;
