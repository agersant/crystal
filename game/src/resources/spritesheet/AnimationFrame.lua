require("src/utils/OOP");

local AnimationFrame = Class("AnimationFrame");

-- PUBLIC API

AnimationFrame.init = function(self, sheetFrame, animationFrameData)
	assert(animationFrameData.ox);
	assert(animationFrameData.oy);
	self._sheetFrame = sheetFrame;
	self._duration = animationFrameData.duration;
	self._ox = animationFrameData.ox;
	self._oy = animationFrameData.oy;
	self._tags = {};

	if animationFrameData.tags then
		for tagName, tagData in pairs(animationFrameData.tags) do
			assert(tagData.rect);
			assert(type(tagData.rect.x) == "number");
			assert(type(tagData.rect.y) == "number");
			assert(type(tagData.rect.w) == "number");
			assert(type(tagData.rect.h) == "number");
			local w = tagData.rect.w;
			local h = tagData.rect.h;
			local x = tagData.rect.x;
			local y = tagData.rect.y;
			if w < 0 then
				x = x + w;
				w = -w;
			end
			if h < 0 then
				y = y + h;
				h = -h;
			end
			x = x + w / 2;
			y = y + h / 2;
			local shape = love.physics.newRectangleShape(x, y, w, h);
			self._tags[tagName] = shape;
		end
	end

end

AnimationFrame.getOrigin = function(self) return self._ox, self._oy; end

AnimationFrame.getDuration = function(self) return self._duration; end

AnimationFrame.getSheetFrame = function(self) return self._sheetFrame; end

AnimationFrame.getTagShape = function(self, tagName) return self._tags[tagName]; end

return AnimationFrame;
