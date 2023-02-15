local Drawable = require("mapscene/display/Drawable");
local Shader = require("mapscene/display/Shader");

local DrawableSystem = Class("DrawableSystem", crystal.System);

local sortDrawables = function(a, b)
	return a:getZOrder() < b:getZOrder();
end

DrawableSystem.init = function(self, ecs)
	DrawableSystem.super.init(self, ecs);
end

DrawableSystem.duringEntitiesDraw = function(self)
	local ecs = self:ecs();
	local drawables = ecs:components(Drawable);
	table.sort(drawables, sortDrawables);
	for _, drawable in ipairs(drawables) do
		local entity = drawable:entity();
		local shader = entity:component(Shader);
		if shader then
			shader:apply();
		end
		drawable:draw();
		if shader then
			love.graphics.setShader(nil);
		end
	end
end

return DrawableSystem;
