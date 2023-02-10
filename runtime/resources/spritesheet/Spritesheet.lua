local Animation = require("resources/spritesheet/Animation");

local Spritesheet = Class("Spritesheet");

Spritesheet.init = function(self, sheetData, texture)
	assert(sheetData);
	assert(texture);
	self._animations = {};
	for k, animationData in pairs(sheetData.content.animations) do
		assert(not self._animations[k]);
		self._animations[k] = Animation:new(texture, sheetData.content.frames, animationData);
	end
end

Spritesheet.getAnimation = function(self, animationName)
	return self._animations[animationName];
end

return Spritesheet;
