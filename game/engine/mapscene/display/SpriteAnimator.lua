require("engine/utils/OOP");
local Behavior = require("engine/mapscene/behavior/Behavior");
local Sprite = require("engine/mapscene/display/Sprite");

local SpriteAnimator = Class("SpriteAnimator", Behavior);

local jumpToFrame = function(self, animationFrame)
	assert(animationFrame);
	self._animationFrame = animationFrame;
	local frame = animationFrame:getFrame();
	self._sprite:setFrame(frame);
end

local playback = function(self, animation)
	local animator = self;
	return function(self)
		local startTime = self:getTime();
		while true do
			local timeElasped = self:getTime() - startTime;
			jumpToFrame(animator, animation:getFrameAtTime(timeElasped));
			if timeElasped >= animation:getDuration() and not animation:isLooping() then
				break
			else
				self:waitFrame();
			end
		end
	end;
end

local playAnimationInternal = function(self, animationName, forceRestart)
	local animation = self._sheet:getAnimation(animationName);
	assert(animation);
	if animation == self._animation and not forceRestart then
		return;
	end
	self._animation = animation;
	self._script:stopAllThreads();
	return self._script:addThreadAndRun(playback(self, animation));
end

SpriteAnimator.init = function(self, sprite, sheet)
	SpriteAnimator.super.init(self);
	assert(sprite);
	assert(sprite:isInstanceOf(Sprite));
	self._sprite = sprite;
	self._sheet = sheet;
	self._animation = nil;
	self._animationFrame = nil;
end

SpriteAnimator.setAnimation = function(self, animationName)
	playAnimationInternal(self, animationName, false);
end

SpriteAnimator.playAnimation = function(self, animationName)
	local thread = playAnimationInternal(self, animationName, true);
	assert(thread);
	return thread;
end

SpriteAnimator.getTagShape = function(self, tagName)
	if self._animationFrame then
		return self._animationFrame:getTagShape(tagName);
	end
end

return SpriteAnimator;
