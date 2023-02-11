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
	assert(sprite:is_instance_of(Sprite));
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

--#region Tests

local Entity = require("ecs/Entity");
local ScriptRunner = require("mapscene/behavior/ScriptRunner");
local Script = require("script/Script");

crystal.test.add("Set animation updates current frame", function()
	local sheet = ASSETS:getSpritesheet("test-data/blankey.lua");
	local sprite = Sprite:new();
	local animator = SpriteAnimator:new(sprite, sheet);
	assert(not sprite:getFrame());
	animator:setAnimation("hurt");
	assert(sprite:getFrame());
end);

crystal.test.add("Cycles through animation frames", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");
	local sheet = ASSETS:getSpritesheet("test-data/blankey.lua");

	local entity = scene:spawn(Entity);
	local sprite = entity:addComponent(Sprite:new());
	local animator = entity:addComponent(SpriteAnimator:new(sprite, sheet));
	entity:addComponent(ScriptRunner:new());

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
	local scene = MapScene:new("test-data/empty_map.lua");
	local sheet = ASSETS:getSpritesheet("test-data/blankey.lua");

	local entity = scene:spawn(Entity);
	local sprite = entity:addComponent(Sprite:new());
	entity:addComponent(SpriteAnimator:new(sprite, sheet));
	entity:addComponent(ScriptRunner:new());

	local sentinel = false;
	entity:addScript(Script:new(function(self)
		self:join(self:playAnimation("hurt"));
		sentinel = true;
	end));

	assert(not sentinel);
	scene:update(0.05);
	assert(not sentinel);
	scene:update(1);
	assert(sentinel);
end);

crystal.test.add("Looping animation thread never ends", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");
	local sheet = ASSETS:getSpritesheet("test-data/blankey.lua");

	local entity = scene:spawn(Entity);
	local sprite = entity:addComponent(Sprite:new());
	entity:addComponent(SpriteAnimator:new(sprite, sheet));
	entity:addComponent(ScriptRunner:new());

	local sentinel = false;
	entity:addScript(Script:new(function(self)
		self:join(self:playAnimation("floating"));
		sentinel = true;
	end));

	assert(not sentinel);
	scene:update(0.05);
	assert(not sentinel);
	scene:update(1000);
	assert(not sentinel);
end);

--#endregion

return SpriteAnimator;
