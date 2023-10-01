local features = require(CRYSTAL_RUNTIME .. "features");

---@alias ScalingMode "none" | "pixel_perfect" | "crop_or_squish"

local lg; -- # Original love.graphics functions

---@class Window
---@field private native_height number
---@field private min_aspect_ratio number
---@field private max_aspect_ratio number
---@field private scaling_mode ScalingMode
---@field private safe_area number
---@field private window_width number
---@field private window_height number
---@field private letterbox_width number
---@field private letterbox_height number
---@field package viewport_width number
---@field package viewport_height number
---@field package viewport_scale number
---@field private viewport_canvas love.Canvas[]
---@field private frame_capture_canvas love.Canvas
---@field private previous_frame_canvas love.Canvas
---@field private current_frame_canvas love.Canvas
local Window = Class("Window");

Window.init = function(self)
	self.native_height = 600;
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
	self.viewport_canvas = {};
	self.frame_capture_canvas = nil;
	self.previous_frame_canvas = nil;
	self.current_frame_canvas = nil;
end

---@package
---@param height number
Window.set_native_height = function(self, height)
	assert(height > 0);
	self.native_height = height;
	self:update();
end

---@package
---@param min number
---@param max number
Window.set_aspect_ratio_limits = function(self, min, max)
	assert(max >= min);
	self.min_aspect_ratio = min;
	self.max_aspect_ratio = max;
	self:update();
end

---@package
---@param scaling_mode ScalingMode
Window.set_scaling_mode = function(self, scaling_mode)
	assert(scaling_mode == "none"
		or scaling_mode == "pixel_perfect"
		or scaling_mode == "crop_or_squish"
	);
	self.scaling_mode = scaling_mode;
	self:update();
end

---@package
---@param fraction number
Window.set_safe_area = function(self, fraction)
	assert(fraction >= 0)
	assert(fraction <= 1)
	self.safe_area = fraction;
	self:update();
end

---@package
Window.update = function(self)
	local old_viewport_width = self.viewport_width;
	local old_viewport_height = self.viewport_height;
	local old_viewport_scale = self.viewport_scale;

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
		self.viewport_scale = math.max(1, math.floor(self.letterbox_height / self.viewport_height));
	elseif self.scaling_mode == "crop_or_squish" then
		local scale_x = (self.letterbox_width + 1) / self.viewport_width;
		local scale_y = (self.letterbox_height + 1) / self.viewport_height;
		local scale = math.max(scale_x, scale_y);
		local w = self.viewport_width * math.ceil(scale);
		local h = self.viewport_height * math.ceil(scale);
		if self.letterbox_width / w >= self.safe_area and self.letterbox_height / h >= self.safe_area then
			self.viewport_scale = math.ceil(scale);
		else
			self.viewport_scale = scale;
		end
	end

	local width_changed = old_viewport_width ~= self.viewport_width;
	local height_changed = old_viewport_height ~= self.viewport_height;
	if width_changed or height_changed then
		for index, canvas in ipairs(self.viewport_canvas) do
			self.viewport_canvas[index] = self:allocate_viewport_canvas();
		end
	end

	if features.frame_capture then
		local scale_changed = old_viewport_scale ~= self.viewport_scale;
		if width_changed or height_changed or scale_changed then
			local w = math.ceil(self.viewport_width * self.viewport_scale);
			local h = math.ceil(self.viewport_height * self.viewport_scale);
			self.frame_capture_canvas = love.graphics.newCanvas(w, h);
			self.previous_frame_canvas = love.graphics.newCanvas(w, h);
			self.current_frame_canvas = love.graphics.newCanvas(w, h);
		end
	end
end

---@package
---@param draw fun()
Window.draw = function(self, draw)
	assert(type(draw) == "function");

	love.graphics.push();

	if self.scaling_mode == "none" then
		local x = math.round((self.window_width - self.viewport_width) / 2);
		local y = math.round((self.window_height - self.viewport_height) / 2);
		love.graphics.setScissor(x, y, self.viewport_width, self.viewport_height);
		love.graphics.translate(x, y);
	elseif self.scaling_mode == "pixel_perfect" then
		local w = self.viewport_width * self.viewport_scale;
		local h = self.viewport_height * self.viewport_scale;
		local x = math.round((self.window_width - w) / 2);
		local y = math.round((self.window_height - h) / 2);
		love.graphics.setScissor(x, y, w, h);
		love.graphics.translate(x, y);
	elseif self.scaling_mode == "crop_or_squish" then
		local x = math.floor((self.window_width - self.letterbox_width) / 2);
		local y = math.floor((self.window_height - self.letterbox_height) / 2);
		love.graphics.setScissor(x, y, self.letterbox_width, self.letterbox_height);
		local crop = self.viewport_scale == math.floor(self.viewport_scale);
		if crop then
			local w = self.viewport_width * self.viewport_scale;
			local h = self.viewport_height * self.viewport_scale;
			love.graphics.translate(math.round((self.window_width - w) / 2), math.round((self.window_height - h) / 2));
		else
			love.graphics.translate(x, y);
		end
	end

	if features.frame_capture then
		-- Draw onto the screen using frame_capture_canvas as intermediate render target
		self:draw_via_canvas(self.frame_capture_canvas,
			function()
				love.graphics.scale(self.viewport_scale, self.viewport_scale);
				draw();
			end,
			function()
				love.graphics.draw(self.frame_capture_canvas);
			end
		);
		-- Draw frame_capture_canvas onto current frame screenshot
		love.graphics.push("all");
		love.graphics.reset();
		love.graphics.setCanvas(self.current_frame_canvas);
		love.graphics.draw(self.frame_capture_canvas);
		love.graphics.pop();
	else
		love.graphics.scale(self.viewport_scale, self.viewport_scale);
		draw();
	end

	love.graphics.pop();
end

---@private
Window.present = function(self)
	if features.frame_capture then
		local swap = self.previous_frame_canvas;
		self.previous_frame_canvas = self.current_frame_canvas;
		self.current_frame_canvas = swap;
		love.graphics.setCanvas(self.current_frame_canvas);
		love.graphics.clear();
		love.graphics.setCanvas(nil);
	end
end

---@private
Window.allocate_viewport_canvas = function(self)
	local canvas = love.graphics.newCanvas(self.viewport_width, self.viewport_height);
	canvas:setFilter("nearest", "nearest");
	return canvas;
end

---@package
---@param draw fun()
Window.draw_native = function(self, draw)
	if table.is_empty(self.viewport_canvas) then
		table.push(self.viewport_canvas, self:allocate_viewport_canvas());
	end
	local canvas = table.remove(self.viewport_canvas);
	self:draw_via_canvas(canvas, draw, function() love.graphics.draw(canvas) end);
	table.push(self.viewport_canvas, canvas);
end

---@package
---@param canvas love.Canvas
---@param draw fun()
---@param blit fun()
Window.draw_via_canvas = function(self, canvas, draw, blit)
	love.graphics.push("all");
	lg.reset();
	love.graphics.setCanvas(canvas);
	love.graphics.clear();
	draw();
	love.graphics.pop();
	blit();
end

local window = Window:new();
local transform_stack = {};

return {
	module_api = {
		viewport_size = function()
			return window.viewport_width, window.viewport_height;
		end,
		viewport_scale = function()
			return window.viewport_scale;
		end,
		draw = function(draw)
			window:draw(draw);
		end,
		draw_native = function(draw)
			window:draw_native(draw);
		end,
		draw_via_canvas = function(canvas, draw, blit)
			window:draw_via_canvas(canvas, draw, blit);
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
		transform = function()
			return transform_stack[#transform_stack]:clone();
		end,
	},
	update = function()
		window:update();
	end,
	present = function()
		window:present();
	end,
	captured_frame = function()
		return window.previous_frame_canvas;
	end,
	start = function()
		lg = table.copy(love.graphics);

		table.push(transform_stack, love.math.newTransform());

		love.graphics.reset = function()
			lg.reset();
			transform_stack[#transform_stack] = love.math.newTransform();
		end

		love.graphics.applyTransform = function(t)
			lg.applyTransform(t);
			table.push(transform_stack, transform_stack[#transform_stack]:clone():transform(t));
		end

		love.graphics.origin = function()
			lg.origin();
			table.clear(transform_stack);
			transform_stack[1] = love.math.newTransform();
		end

		love.graphics.pop = function()
			lg.pop();
			table.pop(transform_stack);
		end

		love.graphics.push = function(s)
			lg.push(s);
			table.push(transform_stack, transform_stack[#transform_stack]:clone());
		end

		love.graphics.replaceTransform = function(t)
			lg.replaceTransform(t);
			transform_stack[#transform_stack] = t;
		end

		love.graphics.rotate = function(a)
			lg.rotate(a);
			transform_stack[#transform_stack]:rotate(a);
		end

		love.graphics.scale = function(sx, sy)
			lg.scale(sx, sy);
			transform_stack[#transform_stack]:scale(sx, sy);
		end

		love.graphics.shear = function(kx, ky)
			lg.shear(kx, ky);
			transform_stack[#transform_stack]:shear(kx, ky);
		end

		love.graphics.translate = function(dx, dy)
			lg.translate(dx, dy);
			transform_stack[#transform_stack]:translate(dx, dy);
		end
	end,
	stop = function()
		love.graphics.reset = lg.reset;
		love.graphics.applyTransform = lg.applyTransform;
		love.graphics.origin = lg.origin;
		love.graphics.pop = lg.pop;
		love.graphics.push = lg.push;
		love.graphics.replaceTransform = lg.replaceTransform;
		love.graphics.rotate = lg.rotate;
		love.graphics.scale = lg.scale;
		love.graphics.shear = lg.shear;
		love.graphics.translate = lg.translate;
	end,
	test_harness = function()
		local width, height = love.window.getMode();
		window:set_scaling_mode("pixel_perfect");
		window:set_native_height(height);
		window:set_aspect_ratio_limits(
			width / height,
			width / height
		);
	end,
};
