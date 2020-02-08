require("engine/utils/OOP");
local System = require("engine/ecs/System");
local Drawable = require("engine/scene/display/Drawable");

local DrawableSystem = Class("DrawableSystem", System);

local sortDrawableEntities = function(entityA, entityB)
	return entityA:getZOrder() < entityB:getZOrder();
end

DrawableSystem.init = function(self, ecs)
	DrawableSystem.super.init(self, ecs);
end

DrawableSystem.draw = function(self)
	local ecs = self:getECS();
	local drawables = ecs:getAllComponents(Drawable);
	table.sort(drawables, sortDrawableEntities);
	for _, drawable in ipairs(drawables) do
		drawable:draw();
	end
end

return DrawableSystem;
