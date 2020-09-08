require("engine/utils/OOP");
local Image = require("engine/resources/Image");
local Animation = require("engine/resources/spritesheet/Animation");

local Spritesheet = Class("Spritesheet");

-- PUBLIC API

Spritesheet.init = function(self, sheetData, texture)
	assert(sheetData);
	assert(texture);
	self._animations = {};
	local frames = {};
	for k, frameData in pairs(sheetData.content.frames) do
		assert(not frames[k]);
		assert(frameData.x);
		assert(frameData.y);
		assert(frameData.w);
		assert(frameData.h);
		frames[k] = Image:new(texture, frameData.x, frameData.y, frameData.w, frameData.h);
	end
	for k, animationData in pairs(sheetData.content.animations) do
		assert(not self._animations[k]);
		self._animations[k] = Animation:new(frames, animationData);
	end
end

Spritesheet.getAnimation = function(self, animationName)
	return self._animations[animationName];
end

return Spritesheet;
