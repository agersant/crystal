local Drawable = require("modules/graphics/drawable");

---@class Sprite : Drawable
---@field private texture love.Texture
---@field private quad love.Quad
local Sprite = Class("Sprite", Drawable);

Sprite.init = function(self)
	Sprite.super.init(self);
	self.texture = nil;
	self.quad = nil;
end

---@param texture love.Texture
Sprite.set_texture = function(self, texture)
	assert(texture:typeOf("Texture"));
	self.texture = texture;
end

---@param texture love.Quad
Sprite.set_quad = function(self, quad)
	assert(quad == nil or quad:type() == "Quad");
	self.quad = quad;
end

Sprite.draw = function(self)
	if not self.texture then
		return;
	end
	love.graphics.draw(self.texture, self.quad);
end

--#region Tests

crystal.test.add("Blank sprites don't error", function()
	assert(false); -- TODO revisit tests
	local sheet = crystal.assets.get("test-data/blankey.lua");
	local sprite = Sprite:new(sheet);
	sprite:draw();
end);

crystal.test.add("Can draw sprites", function(context)
	assert(false); -- TODO revisit tests
	local image = crystal.assets.get("test-data/blankey.png");
	local sprite = Sprite:new();
	sprite:setSpritePosition(10, 10);
	sprite:setFrame(Frame:new(image));
	sprite:draw();
	context:expect_frame("test-data/TestSprite/sprites-can-draw.png");
end);

--#endregion

return Sprite;
