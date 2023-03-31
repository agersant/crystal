local Drawable = require("modules/graphics/drawable");

---@class SpriteBatch : Drawable
---@field private batch love.SpriteBatch
local SpriteBatch = Class("SpriteBatch", Drawable);

SpriteBatch.init = function(self, batch)
	assert(batch:typeOf("SpriteBatch"));
	SpriteBatch.super.init(self);
	self.batch = batch;
end

---@param texture love.SpriteBatch
SpriteBatch.set_sprite_batch = function(self, batch)
	assert(batch:typeOf("SpriteBatch"));
	self.batch = batch;
end

SpriteBatch.draw = function(self)
	love.graphics.draw(self.batch);
end

return SpriteBatch;
