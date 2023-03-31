local AnimatedSprite = require("modules/graphics/animated_sprite");
local Drawable = require("modules/graphics/drawable");
local DrawEffect = require("modules/graphics/draw_effect")
local WorldWidget = require("modules/graphics/world_widget")

---@class DrawSystem : System
---@field private drawables Query
---@field private animated_sprites Query
---@field private world_widgets Query
local DrawSystem = Class("DrawSystem", crystal.System);

DrawSystem.init = function(self)
	self.drawables = self:add_query({ Drawable });
	self.animated_sprites = self:add_query({ AnimatedSprite });
	self.world_widgets = self:add_query({ WorldWidget });
end

---@param a Drawable
---@param b Drawable
local compare_drawables = function(a, b)
	return a:draw_order() < b:draw_order();
end

DrawSystem.update_drawables = function(self, dt)
	for animated_sprite in pairs(self.animated_sprites:components()) do
		animated_sprite:update_sprite_animation(dt);
	end
	for world_widget in pairs(self.world_widgets:components()) do
		world_widget:update_widget(dt);
	end
end

DrawSystem.draw_entities = function(self)
	local sorted = {};
	for drawable in pairs(self.drawables:components()) do
		table.push(sorted, drawable);
	end
	table.sort(sorted, compare_drawables);

	for _, drawable in ipairs(sorted) do
		love.graphics.push("all");
		local entity = drawable:entity();
		local body = entity:component(crystal.Body);
		local effects = entity:components(DrawEffect);

		local x, y = drawable:draw_offset();
		if body then
			local bx, by = body:position();
			x = x + bx;
			y = y + by;
		end
		love.graphics.translate(math.round(x), math.round(y));

		for effect, _ in pairs(effects) do
			effect:pre_draw();
		end

		drawable:draw();

		for effect, _ in pairs(effects) do
			effect:post_draw();
		end

		love.graphics.pop();
	end
end

return DrawSystem;
