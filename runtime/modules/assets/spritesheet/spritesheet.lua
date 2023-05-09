local Animation = require(CRYSTAL_RUNTIME .. "modules/assets/spritesheet/animation");

---@class Spritesheet
---@field private _image love.Image
---@field private animations { [string]: Animation }
local Spritesheet = Class("Spritesheet");

Spritesheet.init = function(self, image)
	assert(image:typeOf("Image"));
	self._image = image;
	self.animations = {};
end

---@param name string
---@param animation Animation
Spritesheet.add_animation = function(self, name, animation)
	self.animations[name] = animation;
end

---@param name string
---@return Animation
Spritesheet.animation = function(self, name)
	assert(type(name) == "string");
	return self.animations[name];
end

---@return love.Image
Spritesheet.image = function(self)
	return self._image;
end

return Spritesheet;
