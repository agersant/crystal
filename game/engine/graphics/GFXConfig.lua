require("engine/utils/OOP");
local CLI = require("engine/dev/cli/CLI");

local GFXConfig = Class("GFXConfig");
local instance;

local setMode = function(self)
	if not love.window then
		return;
	end
	love.window.setMode(self._windowWidth, self._windowHeight,
                    	{msaa = 8, resizable = true, vsync = false, fullscreen = self._fullscreen});
	love.window.setTitle("Crystal");
end

local refreshZoom = function(self)
	local zx = self._windowWidth / self._renderWidth;
	local zy = self._windowHeight / self._renderHeight;
	self._zoom = math.max(1, math.min(math.floor(zx), math.floor(zy)));
end

love.resize = function(width, height)
	instance._windowWidth = width;
	instance._windowHeight = height;
	refreshZoom(instance);
end

GFXConfig.init = function(self)

	-- How big a screen-filling scene is (multiple of tile size)
	self._gameWidth = 480;
	self._gameHeight = 272;

	-- Game window size when playing at zoom 1
	self._renderWidth = 480;
	self._renderHeight = 270;

	self:setZoom(2);
end

GFXConfig.setWindowSize = function(self, width, height)
	self._windowWidth = width;
	self._windowHeight = height;
	refreshZoom(self);
	setMode(self);
end

GFXConfig.setFullscreenEnabled = function(self, enabled)
	self._fullscreen = enabled;
	setMode(self);
end

GFXConfig.setZoom = function(self, zoom)
	assert(zoom > 0);
	assert(zoom == math.floor(zoom));
	self:setWindowSize(self._renderWidth * zoom, self._renderHeight * zoom);
end

GFXConfig.getZoom = function(self)
	return self._zoom;
end

GFXConfig.setRenderSize = function(self, width, height)
	self._renderWidth = width;
	self._renderHeight = height;
end

GFXConfig.getRenderSize = function(self)
	return self._renderWidth, self._renderHeight;
end

GFXConfig.getWindowSize = function(self)
	return self._windowWidth, self._windowHeight;
end

instance = GFXConfig:new();

local setZoom = function(zoom)
	instance:setZoom(zoom);
end

local enableFullscreen = function()
	instance:setFullscreenEnabled(true);
end

local disableFullscreen = function()
	instance:setFullscreenEnabled(false);
end

CLI:registerCommand("setZoom zoom:number", setZoom);
CLI:registerCommand("enableFullscreen", enableFullscreen);
CLI:registerCommand("disableFullscreen", disableFullscreen);

return instance;
