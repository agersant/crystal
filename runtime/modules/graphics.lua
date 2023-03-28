local AnimatedSprite = require("modules/graphics/animated_sprite")
local Color = require("modules/graphics/color");
local Drawable = require("modules/graphics/drawable")
local DrawEffect = require("modules/graphics/draw_effect")
local DrawOrder = require("modules/graphics/draw_order")
local DrawSystem = require("modules/graphics/draw_system")
local Sprite = require("modules/graphics/sprite")
local SpriteBatch = require("modules/graphics/sprite_batch")
local WorldWidget = require("modules/graphics/world_widget")

return {
	global_api = {
		AnimatedSprite = AnimatedSprite,
		Color = Color,
		Drawable = Drawable,
		DrawEffect = DrawEffect,
		DrawOrder = DrawOrder,
		DrawSystem = DrawSystem,
		Sprite = Sprite,
		SpriteBatch = SpriteBatch,
		WorldWidget = WorldWidget,
	},
};
