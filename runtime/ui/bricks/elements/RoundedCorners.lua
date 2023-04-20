local Painter = require("modules/ui/painter");

local RoundedCorners = Class("RoundedCorners", Painter);

RoundedCorners.init = function(self, radius)
	RoundedCorners.super.init(self, crystal.assets.get(CRYSTAL_RUNTIME .. "/assets/rounded_corners.glsl"));
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

RoundedCorners.configure_shader = function(self, shader)
	local radii = { self._topLeftRadius, self._topRightRadius, self._bottomRightRadius, self._bottomLeftRadius };
	shader:send("radii", radii);
	shader:send("drawSize", { self:size() });
	shader:send("textureSize", { self._quad:getTextureDimensions() });
end

return RoundedCorners;
