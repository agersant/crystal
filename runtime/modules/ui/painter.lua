local BasicJoint = require("modules/ui/basic_joint");
local Wrapper = require("modules/ui/wrapper");

---@class Painter : Wrapper
---@field private _shader love.Shader
---@field private _canvas love.Canvas
---@field private _quad love.love.Quad
local Painter = Class("Painter", Wrapper);

Painter.init = function(self, shader)
	Painter.super.init(self, BasicJoint);
	self._shader = shader;
	self._canvas = nil;
	self._quad = nil;
end

---@return love.Shader
Painter.shader = function(self)
	return self._shader;
end

---@param shader love.Shader
Painter.set_shader = function(self, shader)
	self._shader = shader;
end

---@protected
Painter.configure_shader = function(self)
end

---@protected
---@return number
---@return number
Painter.compute_desired_size = function(self)
	if self:child() then
		local child_width, child_height = self:child():desired_size();
		return self.child_joint:compute_desired_size(child_width, child_height);
	end
	return 0, 0;
end

---@protected
Painter.arrange_child = function(self)
	if self:child() then
		local width, height = self:size();
		local child_width, child_height = self:child():desired_size();
		local left, right, top, bottom = self.child_joint:compute_relative_position(
			child_width, child_height,
			width, height
		);
		self:child():set_relative_position(left, right, top, bottom);
	end
end

---@protected
Painter.layout = function(self)
	Painter.super.layout(self);
	self:update_canvas();
	self:update_quad();
end

---@private
---@return boolean
Painter.needs_new_canvas = function(self)
	if not self._canvas then
		return true;
	end
	local width, height = self:size();
	local canvas_width, canvas_height = self._canvas:getDimensions();
	return width > canvas_width or height > canvas_height;
end

---@private
Painter.update_canvas = function(self)
	local width, height = self:size();
	if self:needs_new_canvas() then
		local canvas_width = math.pow(2, math.ceil(math.log(width) / math.log(2)));
		local canvas_height = math.pow(2, math.ceil(math.log(height) / math.log(2)));
		self._canvas = love.graphics.newCanvas(canvas_width, canvas_height);
		self._quad = love.graphics.newQuad(0, 0, width, height, self._canvas);
	end
end

---@private
Painter.update_quad = function(self)
	local width, height = self:size();
	self._quad:setViewport(0, 0, width, height);
end

---@protected
Painter.draw_self = function(self)
	if self:child() then
		assert(self._canvas);
		assert(self._quad);
		if not self._shader then
			self:child():draw();
		else
			love.graphics.push("all");
			love.graphics.reset();
			love.graphics.setCanvas(self._canvas);
			self:child():draw();
			love.graphics.pop();

			love.graphics.push("all");
			love.graphics.setShader(self._shader);
			self:configure_shader(self._shader);
			love.graphics.draw(self._canvas, self._quad);
			love.graphics.pop();
		end
	end
end

return Painter;
