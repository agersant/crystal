require("engine/utils/OOP");
local Component = require("engine/ecs/Component");

local Drawable = Class("Drawable", Component);

-- PUBLIC API

Drawable.init = function(self)
	Drawable.super.init(self);
end

Drawable.awake = function(self)
	self:getEntity():addDrawable(self);
end

-- TODO remove from renderer when component is removed

Drawable.draw = function(self, x, y)
end

Drawable.drawShape = function(self, x, y, shape, color)
	love.graphics.push();
	love.graphics.translate(x, y);
	love.graphics.setColor(color:alpha(.6));
	if shape:getType() == "polygon" then
		love.graphics.polygon("fill", shape:getPoints());
	elseif shape:getType() == "circle" then
		local x, y = shape:getPoint();
		love.graphics.circle("fill", x, y, shape:getRadius(), 16);
	end
	love.graphics.setColor(color);
	if shape:getType() == "polygon" then
		love.graphics.polygon("line", shape:getPoints());
	elseif shape:getType() == "circle" then
		local x, y = shape:getPoint();
		love.graphics.circle("line", x, y, shape:getRadius(), 16);
	end
	love.graphics.pop();
end

return Drawable;
