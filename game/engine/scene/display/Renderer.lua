require("engine/utils/OOP");
local Component = require("engine/ecs/Component");
local Drawable = require("engine/scene/display/Drawable");

local Renderer = Class("Renderer", Component);

-- PUBLIC API

Renderer.init = function(self, scene)
	Renderer.super.init(self, scene);
	self._drawables = {};
end

Renderer.addDrawable = function(self, drawable)
	assert(drawable);
	assert(drawable:isInstanceOf(Drawable));
	self._drawables[drawable] = true;
end

Renderer.draw = function(self)
	local x, y = self:getEntity():getPosition();
	for drawable in pairs(self._drawables) do
		drawable:draw(x, y);
	end
end

Renderer.getZOrder = function(self)
	local _, y = self:getEntity():getPosition();
	return y;
end

return Renderer;
