local BasicJoint = require("modules/ui/basic_joint");
local Wrapper = require("modules/ui/wrapper");

local PainterJoint = Class("PainterJoint", BasicJoint);
local Painter = Class("Painter", Wrapper);

local isCanvasLargeEnough = function(self)
	if not self._canvas then
		return false;
	end
	local width, height = self:size();
	local canvasWidth, canvasHeight = self._canvas:getDimensions();
	return width <= canvasWidth and height <= canvasHeight;
end

PainterJoint.init = function(self, parent, child)
	PainterJoint.super.init(self, parent, child);
end

Painter.init = function(self, shaderResource)
	Painter.super.init(self, PainterJoint);
	self._shaderResource = shaderResource;
	self._canvas = nil;
	self._quad = nil;
end

Painter.getShaderResource = function(self)
	return self._shaderResource;
end

Painter.setShaderResource = function(self, shaderResource)
	self._shaderResource = shaderResource;
end

Painter.configureShader = function(self)
end

Painter.compute_desired_size = function(self)
	if self._child then
		local childWidth, childHeight = self._child:desired_size();
		return self.child_joint:compute_desired_size(childWidth, childHeight);
	end
	return 0, 0;
end

Painter.arrange_child = function(self)
	if self._child then
		local width, height = self:size();
		local childWidth, childHeight = self._child:desired_size();
		local left, right, top, bottom = self.child_joint:compute_relative_position(childWidth, childHeight, width,
			height);
		self._child:set_relative_position(left, right, top, bottom);
	end
end

Painter.layout = function(self)
	Painter.super.layout(self);
	self:allocateCanvas();
	self:updateQuad();
end

Painter.allocateCanvas = function(self)
	local width, height = self:size();
	if not isCanvasLargeEnough(self) then
		local canvasWidth = math.pow(2, math.ceil(math.log(width) / math.log(2)));
		local canvasHeight = math.pow(2, math.ceil(math.log(height) / math.log(2)));
		self._canvas = love.graphics.newCanvas(canvasWidth, canvasHeight);
		self._quad = love.graphics.newQuad(0, 0, width, height, self._canvas);
	end
end

Painter.updateQuad = function(self)
	local width, height = self:size();
	self._quad:setViewport(0, 0, width, height);
end

Painter.draw_self = function(self)
	if self._child then
		assert(self._canvas);
		assert(self._quad);
		if not self._shaderResource then
			self._child:draw();
		else
			love.graphics.push("all");
			love.graphics.reset();
			love.graphics.setCanvas(self._canvas);
			self._child:draw();
			love.graphics.pop();

			love.graphics.push("all");
			love.graphics.setShader(self._shaderResource);
			self:configureShader();
			love.graphics.draw(self._canvas, self._quad);
			love.graphics.pop();
		end
	end
end

return Painter;
