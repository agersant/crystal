local Viewport = Class("Viewport");

local setMode = function(self)
	if not love.window then
		return;
	end
	love.window.setMode(self._windowWidth, self._windowHeight,
		{ msaa = 8, resizable = true, vsync = false, fullscreen = self._fullscreen });
	love.window.setTitle("Crystal");
end

Viewport.init = function(self)
	-- Game window size when playing at zoom 1
	self._renderWidth = 480;
	self._renderHeight = 270;
	self:setZoom(2);
end

Viewport.setWindowSize = function(self, width, height)
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

Viewport.setFullscreenEnabled = function(self, enabled)
	self._fullscreen = enabled;
	setMode(self);
end

Viewport.setZoom = function(self, zoom)
	assert(zoom > 0);
	assert(zoom == math.floor(zoom));
	self:setWindowSize(self._renderWidth * zoom, self._renderHeight * zoom);
end

Viewport.getZoom = function(self)
	return self._zoom;
end

Viewport.setRenderSize = function(self, width, height)
	self._renderWidth = width;
	self._renderHeight = height;
end

Viewport.getRenderSize = function(self)
	return self._renderWidth, self._renderHeight;
end

Viewport.getWindowSize = function(self)
	return self._windowWidth, self._windowHeight;
end

TERMINAL:addCommand("setZoom zoom:number", function(zoom)
	VIEWPORT:setZoom(zoom);
end);

TERMINAL:addCommand("enableFullscreen", function()
	VIEWPORT:setFullscreenEnabled(true);
end);

TERMINAL:addCommand("disableFullscreen", function()
	VIEWPORT:setFullscreenEnabled(false);
end);

return Viewport;
