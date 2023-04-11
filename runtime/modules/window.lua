---@alias ScalingMode "none" | "pixel_perfect" | "crop_or_squish"

---@class Window
---@field package native_height number
---@field package min_aspect_ratio number
---@field package max_aspect_ratio number
---@field package scaling_mode ScalingMode
---@field package safe_area number
---@field package window_width number
---@field package window_height number
---@field package letterbox_width number
---@field package letterbox_height number
---@field package viewport_width number
---@field package viewport_height number
---@field package viewport_scale number
---@field package canvas love.Canvas
local Window = Class("Window");

Window.init = function(self)
	self.native_height = 240;
	self.min_aspect_ratio = 4 / 3;
	self.max_aspect_ratio = 21 / 9;
	self.scaling_mode = "crop_or_squish";
	self.safe_area = 0.90;
	self.window_width = nil;
	self.window_height = nil;
	self.letterbox_width = nil;
	self.letterbox_height = nil;
	self.viewport_width = nil;
	self.viewport_height = nil;
	self.viewport_scale = nil;
	self.canvas = nil;
end

---@param height number
Window.set_native_height = function(self, height)
	assert(height > 0);
	self.native_height = height;
	self:update();
end

---@param min number
---@param max number
Window.set_aspect_ratio_limits = function(self, min, max)
	assert(max >= min);
	self.min_aspect_ratio = min;
	self.max_aspect_ratio = max;
	self:update();
end

---@param scaling_mode ScalingMode
Window.set_scaling_mode = function(self, scaling_mode)
	assert(scaling_mode == "none"
		or scaling_mode == "pixel_perfect"
		or scaling_mode == "crop_or_squish"
	);
	self.scaling_mode = scaling_mode;
	self:update();
end

---@param fraction number
Window.set_safe_area = function(self, fraction)
	assert(fraction >= 0)
	assert(fraction <= 1)
	self.safe_area = fraction;
	self:update();
end

---@package
Window.update = function(self)
	local window_width, window_height, _ = love.window.getMode();
	self.window_width = window_width;
	self.window_height = window_height;

	local window_aspect_ratio = self.window_width / self.window_height;
	local game_aspect_ratio = math.clamp(window_aspect_ratio, self.min_aspect_ratio, self.max_aspect_ratio);
	if window_aspect_ratio >= game_aspect_ratio then
		self.letterbox_width = math.round(game_aspect_ratio * self.window_height);
		self.letterbox_height = self.window_height;
	else
		self.letterbox_width = self.window_width;
		self.letterbox_height = math.round(self.window_width / game_aspect_ratio);
	end

	self.viewport_width = math.round(game_aspect_ratio * self.native_height);
	self.viewport_height = self.native_height;
	if self.scaling_mode == "none" then
		self.viewport_scale = 1;
	elseif self.scaling_mode == "pixel_perfect" then
		self.viewport_scale = math.floor(self.letterbox_height / self.viewport_height);
	elseif self.scaling_mode == "crop_or_squish" then
		self.viewport_scale = math.ceil(self.letterbox_height / self.viewport_height);
	end

	local canvas_w, canvas_h = 0, 0;
	if self.canvas then
		canvas_w, canvas_h = self.canvas:getDimensions();
	end
	if canvas_w ~= self.viewport_width or canvas_h ~= self.viewport_height then
		self.canvas = love.graphics.newCanvas(self.viewport_width, self.viewport_height);
		self.canvas:setFilter("nearest", "nearest");
	end
end

---@package
Window.scale = function(self, draw)
	love.graphics.push("all");
	if self.scaling_mode == "none" then
		local x = math.floor((self.window_width - self.viewport_width) / 2);
		local y = math.floor((self.window_height - self.viewport_height) / 2);
		love.graphics.setScissor(x, y, self.viewport_width, self.viewport_height);
		love.graphics.translate(x, y);
	elseif self.scaling_mode == "pixel_perfect" then
		local w = self.viewport_width * self.viewport_scale;
		local h = self.viewport_height * self.viewport_scale;
		local x = math.floor((self.window_width - w) / 2);
		local y = math.floor((self.window_height - h) / 2);
		love.graphics.setScissor(x, y, w, h);
		love.graphics.translate(x, y);
		love.graphics.scale(self.viewport_scale, self.viewport_scale);
	elseif self.scaling_mode == "crop_or_squish" then
		local w = self.viewport_width * self.viewport_scale;
		local h = self.viewport_height * self.viewport_scale;
		local x = math.floor((self.window_width - self.letterbox_width) / 2);
		local y = math.floor((self.window_height - self.letterbox_height) / 2);
		love.graphics.setScissor(x, y, self.letterbox_width, self.letterbox_height);
		if self.letterbox_height / h >= self.safe_area then
			love.graphics.translate(math.floor((self.window_width - w) / 2), math.floor((self.window_height - h) / 2));
			love.graphics.scale(self.viewport_scale, self.viewport_scale);
		else
			love.graphics.translate(x, y);
			love.graphics.scale(self.letterbox_width / self.viewport_width, self.letterbox_height / self.viewport_height);
		end
	end
	draw();
	love.graphics.pop();
end

---@param draw fun()
Window.draw_native = function(self, draw)
	assert(type(draw) == "function");
	self:scale(function()
		draw();
	end);
end

---@param draw fun()
Window.draw_upscaled = function(self, draw)
	assert(type(draw) == "function");

	love.graphics.push("all");
	love.graphics.setCanvas(self.canvas);
	love.graphics.clear();
	draw();
	love.graphics.pop();

	self:scale(function()
		love.graphics.draw(self.canvas);
	end);
end

local window = Window:new();

return {
	module_api = {
		viewport_size = function()
			return window.viewport_width, window.viewport_height;
		end,
		viewport_scale = function()
			return window.viewport_scale;
		end,
		draw_native = function(draw)
			window:draw_native(draw);
		end,
		draw_upscaled = function(draw)
			window:draw_upscaled(draw);
		end,
		set_native_height = function(height)
			window:set_native_height(height);
		end,
		set_aspect_ratio_limits = function(min, max)
			window:set_aspect_ratio_limits(min, max);
		end,
		set_scaling_mode = function(scaling_mode)
			window:set_scaling_mode(scaling_mode);
		end,
		set_safe_area = function(fraction)
			window:set_safe_area(fraction);
		end,
	},
	update = function()
		window:update();
	end,
};
