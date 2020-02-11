require("engine/utils/OOP");
local System = require("engine/ecs/System");
local Drawable = require("engine/mapscene/display/Drawable");

local DrawableSystem = Class("DrawableSystem", System);

local sortDrawables = function(a, b)
	return a:getZOrder() < b:getZOrder();
end

DrawableSystem.init = function(self, ecs)
	DrawableSystem.super.init(self, ecs);
end

DrawableSystem.draw = function(self)
	local ecs = self:getECS();
	local drawables = ecs:getAllComponents(Drawable);
	table.sort(drawables, sortDrawables);
	for _, drawable in ipairs(drawables) do
		drawable:draw();
	end
end

return DrawableSystem;
