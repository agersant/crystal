local UIElement = require(CRYSTAL_RUNTIME .. "modules/ui/ui_element");

---@class Image : UIElement
---@field private _texture love.Texture
---@field private image_width number
---@field private image_height number
local Image = Class("Image", UIElement);

Image.init = function(self, texture)
	Image.super.init(self);
	self.image_width = 1;
	self.image_height = 1;
	if texture then
		self:set_texture(texture, true);
	end
end

---@return love.Texture
Image.texture = function(self)
	return self._texture;
end

---@param texture love.Texture
---@param adopt_size boolean
Image.set_texture = function(self, texture, adopt_size)
	self._texture = texture;
	if adopt_size then
		if self._texture then
			self:set_image_size(self._texture:getWidth(), self._texture:getHeight());
		else
			self:set_image_size(1, 1);
		end
	end
end

---@param width number
---@param height number
Image.set_image_size = function(self, width, height)
	self.image_width = width;
	self.image_height = height;
end

---@return number
---@return number
Image.image_size = function(self)
	return self.image_width, self.image_height;
end

---@protected
Image.compute_desired_size = function(self)
	return self.image_width, self.image_height;
end

---@protected
Image.draw_self = function(self)
	-- TODO pixel snapping?
	local w, h = self:size();
	if self._texture then
		local rotation = 0;
		local scale_x = w / self._texture:getWidth();
		local scale_y = h / self._texture:getHeight();
		love.graphics.draw(self._texture, 0, 0, rotation, scale_x, scale_y);
	else
		love.graphics.rectangle("fill", 0, 0, w, h);
	end
end

return Image;
