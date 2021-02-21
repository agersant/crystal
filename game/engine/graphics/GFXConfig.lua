require("engine/utils/OOP");
-- TODO rename to Viewport
local GFXConfig = Class("GFXConfig");

local setMode = function(self)
	if not love.window then
		return;
	end
	love.window.setMode(self._windowWidth, self._windowHeight,
                    	{msaa = 8, resizable = true, vsync = false, fullscreen = self._fullscreen});
	love.window.setTitle("Crystal");
end

GFXConfig.init = function(self)
	-- Game window size when playing at zoom 1
	self._renderWidth = 480;
	self._renderHeight = 270;
	self:setZoom(2);
end

GFXConfig.setWindowSize = function(self, width, height)
	if self._windowWidth == width and self._windowHeight == height then
		return;
	end
	self._windowWidth = width;
	self._windowHeight = height;
	local zx = self._windowWidth / self._renderWidth;
	local zy = self._windowHeight / self._renderHeight;
	self._zoom = math.max(1, math.min(math.floor(zx), math.floor(zy)));
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

local setZoom = function(zoom)
	VIEWPORT:setZoom(zoom);
end

local enableFullscreen = function()
	VIEWPORT:setFullscreenEnabled(true);
end

local disableFullscreen = function()
	VIEWPORT:setFullscreenEnabled(false);
end

TERMINAL:addCommand("setZoom zoom:number", setZoom);
TERMINAL:addCommand("enableFullscreen", enableFullscreen);
TERMINAL:addCommand("disableFullscreen", disableFullscreen);

return GFXConfig;
