local Drawable = require("modules/graphics/drawable");

---@class SpriteBatch : Drawable
---@field private batch love.SpriteBatch
local SpriteBatch = Class("SpriteBatch", Drawable);

SpriteBatch.init = function(self, batch)
	assert(batch == nil or batch:typeOf("SpriteBatch"));
	SpriteBatch.super.init(self);
	self.batch = batch;
end

---@return love.SpriteBatch
SpriteBatch.sprite_batch = function(self)
	return self.batch;
end

---@param batch love.SpriteBatch
SpriteBatch.set_sprite_batch = function(self, batch)
	assert(batch == nil or batch:typeOf("SpriteBatch"));
	self.batch = batch;
end

SpriteBatch.draw = function(self)
	if self.batch then
		love.graphics.draw(self.batch);
	end
end

return SpriteBatch;
