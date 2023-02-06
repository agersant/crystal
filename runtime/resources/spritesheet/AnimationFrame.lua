local AnimationFrame = Class("AnimationFrame");

AnimationFrame.init = function(self, frame, duration, tags)
	assert(frame);
	assert(duration);
	self._frame = frame;
	self._duration = duration;
	self._tags = {};

	if tags then
		for tagName, tagData in pairs(tags) do
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

AnimationFrame.getDuration = function(self)
	return self._duration;
end

AnimationFrame.getFrame = function(self)
	return self._frame;
end

AnimationFrame.getTagShape = function(self, tagName)
	return self._tags[tagName];
end

return AnimationFrame;
