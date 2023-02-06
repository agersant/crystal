local Behavior = require("mapscene/behavior/Behavior");
local Sprite = require("mapscene/display/Sprite");

local SpriteAnimator = Class("SpriteAnimator", Behavior);

local jumpToFrame = function(self, animationFrame)
	assert(animationFrame);
	self._animationFrame = animationFrame;
	local frame = animationFrame:getFrame();
	self._sprite:setFrame(frame);
end

local playback = function(self, sequence)
	assert(sequence);
	local animator = self;
	return function(self)
		local startTime = self:getTime();
		while true do
			local timeElasped = self:getTime() - startTime;
			jumpToFrame(animator, sequence:getFrameAtTime(timeElasped));
			if timeElasped >= sequence:getDuration() and not sequence:isLooping() then
				break
			else
				self:waitFrame();
			end
		end
	end;
end

local playAnimationInternal = function(self, animationName, angle, forceRestart)
	local animation = self._sheet:getAnimation(animationName);
	assert(animation);
	local sequence = animation:getSequence(angle or math.pi / 2);
	assert(sequence);
	if sequence == self._sequence and not forceRestart then
		return;
	end
	self._sequence = sequence;
	self._script:stopAllThreads();
	return self._script:addThreadAndRun(playback(self, sequence));
end

SpriteAnimator.init = function(self, sprite, sheet)
	SpriteAnimator.super.init(self);
	assert(sprite);
	assert(sprite:isInstanceOf(Sprite));
	self._sprite = sprite;
	self._sheet = sheet;
	self._sequence = nil;
	self._animationFrame = nil;
end

SpriteAnimator.setAnimation = function(self, animationName, angle)
	playAnimationInternal(self, animationName, angle, false);
end

SpriteAnimator.playAnimation = function(self, animationName, angle)
	local thread = playAnimationInternal(self, animationName, angle, true);
	assert(thread);
	return thread;
end

SpriteAnimator.getTagShape = function(self, tagName)
	if self._animationFrame then
		return self._animationFrame:getTagShape(tagName);
	end
end

return SpriteAnimator;
