require("engine/utils/OOP");
local GFXConfig = require("engine/graphics/GFXConfig");

local Renderer = Class("Renderer");

local letterbox = function(self, draw)
	local windowWidth, windowHeight = GFXConfig:getWindowSize();
	local renderWidth, renderHeight = GFXConfig:getRenderSize();
	local nativeWidth, nativeHeight = GFXConfig:getNativeSize();
	local zoom = GFXConfig:getZoom();

	local letterboxWidth = renderWidth * zoom;
	local letterboxHeight = renderHeight * zoom;
	local letterboxX = math.floor((windowWidth - renderWidth * zoom) / 2);
	local letterboxY = math.floor((windowHeight - renderHeight * zoom) / 2);

	love.graphics.push("all");
	love.graphics.setScissor(letterboxX, letterboxY, letterboxWidth, letterboxHeight);
	love.graphics.translate(letterboxX, letterboxY);
	love.graphics.translate(zoom * (renderWidth - nativeWidth) / 2, zoom * (renderHeight - nativeHeight) / 2);
	draw();
	love.graphics.pop();
end

Renderer.init = function(self)
	local renderWidth, renderHeight = GFXConfig:getRenderSize();
	local nativeWidth, nativeHeight = GFXConfig:getNativeSize();
	assert(nativeWidth >= renderWidth);
	assert(nativeHeight >= renderHeight);
	self._padding = 1; -- Additional pixels rendered so that we have adjacent data when offsetting the scene by (unzoomed) subpixel amounts
	self._canvas = love.graphics.newCanvas(nativeWidth + 2 * self._padding, nativeHeight + 2 * self._padding);
	self._canvas:setFilter("nearest");
end

Renderer.draw = function(self, drawFunction, options)
	options = options or {};

	local subpixelOffsetX = options.subpixelOffsetX or 0;
	local subpixelOffsetY = options.subpixelOffsetY or 0;
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
		local zoom = GFXConfig:getZoom();
		love.graphics.scale(zoom, zoom);
		love.graphics.translate(subpixelOffsetX, subpixelOffsetY);
		if upscale then
			love.graphics.draw(self._canvas);
		else
			drawFunction();
		end
	end);
end

return Renderer;
