local Renderer = Class("Renderer");

local letterbox = function(self, drawFunction)
	local windowWidth, windowHeight = self._viewport:getWindowSize();
	local renderWidth, renderHeight = self._viewport:getRenderSize();
	local zoom = self._viewport:getZoom();

	local letterboxWidth = renderWidth * zoom;
	local letterboxHeight = renderHeight * zoom;
	local letterboxX = math.floor((windowWidth - renderWidth * zoom) / 2);
	local letterboxY = math.floor((windowHeight - renderHeight * zoom) / 2);

	love.graphics.push("all");
	love.graphics.setScissor(letterboxX, letterboxY, letterboxWidth, letterboxHeight);
	love.graphics.translate(letterboxX, letterboxY);
	drawFunction();
	love.graphics.pop();
end

Renderer.init = function(self, viewport)
	assert(viewport);
	self._viewport = viewport;

	local renderWidth, renderHeight = self._viewport:getRenderSize();
	self._padding = 1; -- Additional pixels rendered so that we have adjacent data when offsetting the scene by (unzoomed) subpixel amounts
	self._canvas = love.graphics.newCanvas(renderWidth + 2 * self._padding, renderHeight + 2 * self._padding);
	self._canvas:setFilter("nearest");
end

Renderer.getViewport = function(self)
	return self._viewport;
end

Renderer.draw = function(self, drawFunction, options)
	local renderWidth, renderHeight = self._viewport:getRenderSize();

	options = options or {};
	local subpixelOffsetX = options.subpixelOffsetX or 0;
	local subpixelOffsetY = options.subpixelOffsetY or 0;
	local sceneSizeX = options.sceneSizeX or renderWidth;
	local sceneSizeY = options.sceneSizeY or renderHeight;
	local upscale = not options.nativeResolution;

	assert(math.abs(subpixelOffsetX) <= 1);
	assert(math.abs(subpixelOffsetY) <= 1);

	if upscale then
		love.graphics.push("all");
		love.graphics.setCanvas(self._canvas);
		love.graphics.clear();
		love.graphics.translate(self._padding, self._padding);
		drawFunction();
		love.graphics.pop();
	end

	letterbox(self, function()
		local zoom = self._viewport:getZoom();
		love.graphics.scale(zoom, zoom);
		love.graphics.translate(subpixelOffsetX, subpixelOffsetY);
		love.graphics.translate((renderWidth - sceneSizeX) / 2, (renderHeight - sceneSizeY) / 2);
		if upscale then
			love.graphics.translate(-self._padding, -self._padding);
			love.graphics.draw(self._canvas);
		else
			drawFunction();
		end
	end);
end

return Renderer;
