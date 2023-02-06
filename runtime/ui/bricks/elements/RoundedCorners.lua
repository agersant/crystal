local Painter = require("ui/bricks/elements/Painter");

local RoundedCorners = Class("RoundedCorners", Painter);

RoundedCorners.init = function(self, radius)
	RoundedCorners.super.init(self, ASSETS:getShader("engine/assets/rounded_corners.glsl"));
	self:setAllRadius(radius or 2);
end

RoundedCorners.setTopLeftRadius = function(self, radius)
	assert(radius);
	assert(radius >= 0);
	self._topLeftRadius = radius;
end

RoundedCorners.setTopRightRadius = function(self, radius)
	assert(radius);
	assert(radius >= 0);
	self._topRightRadius = radius;
end

RoundedCorners.setBottomRightRadius = function(self, radius)
	assert(radius);
	assert(radius >= 0);
	self._bottomRightRadius = radius;
end

RoundedCorners.setBottomLeftRadius = function(self, radius)
	assert(radius);
	assert(radius >= 0);
	self._bottomLeftRadius = radius;
end

RoundedCorners.setEachRadius = function(self, topLeft, topRight, bottomRight, bottomLeft)
	self:setTopLeftRadius(topLeft);
	self:setTopRightRadius(topRight);
	self:setBottomRightRadius(bottomRight);
	self:setBottomLeftRadius(bottomLeft);
end

RoundedCorners.setAllRadius = function(self, radius)
	self:setTopLeftRadius(radius);
	self:setTopRightRadius(radius);
	self:setBottomRightRadius(radius);
	self:setBottomLeftRadius(radius);
end

RoundedCorners.configureShader = function(self)
	local radii = { self._topLeftRadius, self._topRightRadius, self._bottomRightRadius, self._bottomLeftRadius };
	self._shaderResource:send("radii", radii);
	self._shaderResource:send("drawSize", { self:getSize() });
	self._shaderResource:send("textureSize", { self._quad:getTextureDimensions() });
end

return RoundedCorners;
