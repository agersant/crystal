local Sprite = require("mapscene/display/Sprite");

local SpriteAnimator = Class("SpriteAnimator", crystal.Behavior);

local jumpToFrame = function(self, animationFrame)
	assert(animationFrame);
	self._animationFrame = animationFrame;
	self._sprite:setImage(self._sheet:image());
	self._sprite:setQuad(animationFrame.quad);
	self._sprite:setOffset(animationFrame.x, animationFrame.y);
end

local playback = function(self, animation, sequence)
	assert(sequence);
	local animator = self;
	return function(self)
		local startTime = self:time();
		while true do
			local loop = animation:is_looping();
			local duration = sequence:duration();
			local t = self:time() - startTime;
			if loop then
				t = t % duration;
			else
				t = math.min(t, duration);
			end
			jumpToFrame(animator, sequence:keyframe(t));
			if t >= duration and not loop then
				break;
			else
				self:wait_frame();
			end
		end
	end;
end

local playAnimationInternal = function(self, animationName, rotation, forceRestart)
	local animation = self._sheet:animation(animationName);
	assert(animation);
	local sequence = animation:sequence(rotation or math.pi / 2);
	assert(sequence);
	if sequence == self._sequence and not forceRestart then
		return;
	end
	self._sequence = sequence;
	self._script:stop_all_threads();
	return self._script:run_thread(playback(self, animation, sequence));
end

SpriteAnimator.init = function(self, sprite, sheet)
	SpriteAnimator.super.init(self);
	assert(sprite);
	assert(sprite:inherits_from(Sprite));
	self._sprite = sprite;
	self._sheet = sheet;
	self._sequence = nil;
	self._animationFrame = nil;
end

SpriteAnimator.setAnimation = function(self, animationName, rotation)
	playAnimationInternal(self, animationName, rotation, false);
end

SpriteAnimator.playAnimation = function(self, animationName, rotation)
	local thread = playAnimationInternal(self, animationName, rotation, true);
	assert(thread);
	return thread;
end

SpriteAnimator.getTagShape = function(self, tagName)
	if self._animationFrame then
		return self._animationFrame.hitboxes[tagName];
	end
end

--#region Tests

crystal.test.add("Set animation updates current frame", function()
	local sheet = crystal.assets.get("test-data/blankey.lua");
	local sprite = Sprite:new();
	local animator = SpriteAnimator:new(sprite, sheet);
	assert(not sprite:getFrame());
	animator:setAnimation("hurt");
	assert(sprite:getFrame());
end);

crystal.test.add("Cycles through animation frames", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty.lua");
	local sheet = crystal.assets.get("test-data/blankey.lua");

	local entity = scene:spawn(crystal.Entity);
	local sprite = entity:add_component(Sprite);
	local animator = entity:add_component(SpriteAnimator, sprite, sheet);
	entity:add_component(crystal.ScriptRunner);

	animator:playAnimation("floating");

	local animation = sheet:getAnimation("floating");
	local sequence = animation:getSequence(0);
	assert(sequence:getFrameAtTime(0) ~= sequence:getFrameAtTime(0.5));

	for t = 0, 500 do
		assert(sprite:getFrame() == sequence:getFrameAtTime(t * 1 / 60):getFrame());
		scene:update(1 / 60);
	end
end);

crystal.test.add("Animation blocks script", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty.lua");
	local sheet = crystal.assets.get("test-data/blankey.lua");

	local entity = scene:spawn(crystal.Entity);
	local sprite = entity:add_component(Sprite);
	entity:add_component(SpriteAnimator, sprite, sheet);
	entity:add_component(crystal.ScriptRunner);

	local sentinel = false;
	entity:add_script(function(self)
		self:join(self:playAnimation("hurt"));
		sentinel = true;
	end);

	assert(not sentinel);
	scene:update(0.05);
	assert(not sentinel);
	scene:update(1);
	assert(sentinel);
end);

crystal.test.add("Looping animation thread never ends", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty.lua");
	local sheet = crystal.assets.get("test-data/blankey.lua");

	local entity = scene:spawn(crystal.Entity);
	local sprite = entity:add_component(Sprite);
	entity:add_component(SpriteAnimator, sprite, sheet);
	entity:add_component(crystal.ScriptRunner);

	local sentinel = false;
	entity:add_script(function(self)
		self:join(self:playAnimation("floating"));
		sentinel = true;
	end);

	assert(not sentinel);
	scene:update(0.05);
	assert(not sentinel);
	scene:update(1000);
	assert(not sentinel);
end);

--#endregion

return SpriteAnimator;
