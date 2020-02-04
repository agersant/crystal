require("engine/utils/OOP");

local SheetFrame = Class("SheetFrame");

-- PUBLIC API

SheetFrame.init = function(self, frameData, image)
	assert(type(frameData.x) == "number");
	assert(type(frameData.y) == "number");
	assert(type(frameData.w) == "number");
	assert(type(frameData.h) == "number");
	self._quad = love.graphics.newQuad(frameData.x, frameData.y, frameData.w, frameData.h, image:getDimensions());
end

SheetFrame.getQuad = function(self)
	return self._quad;
end

return SheetFrame;
