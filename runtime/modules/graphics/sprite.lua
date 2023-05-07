local Drawable = require(CRYSTAL_RUNTIME .. "/modules/graphics/drawable");

---@class Sprite : Drawable
---@field private _texture love.Texture
---@field private _quad love.Quad
local Sprite = Class("Sprite", Drawable);

Sprite.init = function(self, texture, quad)
	assert(texture == nil or texture:typeOf("Texture"));
	assert(quad == nil or quad:type() == "Quad");
	Sprite.super.init(self);
	self._texture = texture;
	self._quad = quad;
end

---@return love.Texture
Sprite.texture = function(self)
	return self._texture;
end

---@param texture love.Texture
Sprite.set_texture = function(self, texture)
	assert(texture == nil or texture:typeOf("Texture"));
	self._texture = texture;
end

---@return love.Quad
Sprite.quad = function(self)
	return self._quad;
end

---@param quad love.Quad
Sprite.set_quad = function(self, quad)
	assert(quad == nil or quad:type() == "Quad");
	self._quad = quad;
end

Sprite.draw = function(self)
	if not self._texture then
		return;
	end
	love.graphics.draw(self._texture, self._quad);
end

--#region Tests

crystal.test.add("Blank sprites don't error", function()
	local sprite = Sprite:new();
	sprite:draw();
end);

crystal.test.add("Can draw sprites", function(context)
	local image = crystal.assets.get("test-data/blankey.png");
	local sprite = Sprite:new();
	sprite:set_draw_offset(10, 10);
	sprite:set_texture(image);
	sprite:draw();
	context:expect_frame("test-data/can-draw-sprites.png");
end);

--#endregion

return Sprite;
