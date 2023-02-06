local System = require("ecs/System");
local Drawable = require("mapscene/display/Drawable");
local Shader = require("mapscene/display/Shader");

local DrawableSystem = Class("DrawableSystem", System);

local sortDrawables = function(a, b)
	return a:getZOrder() < b:getZOrder();
end

DrawableSystem.init = function(self, ecs)
	DrawableSystem.super.init(self, ecs);
end

DrawableSystem.duringEntitiesDraw = function(self)
	local ecs = self:getECS();
	local drawables = ecs:getAllComponents(Drawable);
	table.sort(drawables, sortDrawables);
	for _, drawable in ipairs(drawables) do
		local entity = drawable:getEntity();
		local shader = entity:getComponent(Shader);
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
