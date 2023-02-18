local Drawable = require("mapscene/display/Drawable");
local Shader = require("mapscene/display/Shader");

local DrawableSystem = Class("DrawableSystem", crystal.System);

DrawableSystem.init = function(self)
	self.query = self:add_query({ "Drawable" });
end

local sortDrawables = function(a, b)
	return a:getZOrder() < b:getZOrder();
end

DrawableSystem.duringEntitiesDraw = function(self)
	local sorted_drawables = {};
	for drawable in pairs(self.query:components("Drawable")) do
		table.insert(sorted_drawables, drawable);
	end
	table.sort(sorted_drawables, sortDrawables);

	for _, drawable in ipairs(sorted_drawables) do
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
