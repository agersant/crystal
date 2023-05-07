local AnimatedSprite = require(CRYSTAL_RUNTIME .. "/modules/graphics/animated_sprite")
local Color = require(CRYSTAL_RUNTIME .. "/modules/graphics/color");
local Drawable = require(CRYSTAL_RUNTIME .. "/modules/graphics/drawable")
local DrawEffect = require(CRYSTAL_RUNTIME .. "/modules/graphics/draw_effect")
local DrawOrder = require(CRYSTAL_RUNTIME .. "/modules/graphics/draw_order")
local DrawSystem = require(CRYSTAL_RUNTIME .. "/modules/graphics/draw_system")
local Sprite = require(CRYSTAL_RUNTIME .. "/modules/graphics/sprite")
local SpriteBatch = require(CRYSTAL_RUNTIME .. "/modules/graphics/sprite_batch")
local WorldWidget = require(CRYSTAL_RUNTIME .. "/modules/graphics/world_widget")

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
