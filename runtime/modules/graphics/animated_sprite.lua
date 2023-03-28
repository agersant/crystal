local Sprite = require("modules/graphics/sprite");
local Script = require("modules/script/script");

---@class AnimatedSprite : Sprite
---@field private script Script
---@field private spritesheet Spritesheet
---@field private sequence Sequence
---@field private keyframe Keyframe
local AnimatedSprite = Class("AnimatedSprite", Sprite);

AnimatedSprite.init = function(self, spritesheet)
	AnimatedSprite.super.init(self);
	assert(spritesheet:inherits_from("Spritesheet"));
	self.script = Script:new();
	self.spritesheet = spritesheet;
	self.sequence = nil;
	self.keyframe = nil;
end

AnimatedSprite.update_sprite_animation = function(self, dt)
	self.script:update(dt);
end

---@param name string
---@return love.Shape
AnimatedSprite.sprite_hitbox = function(self, name)
	if self.keyframe then
		return self.keyframe.hitboxes[name];
	end
end

AnimatedSprite.set_animation = function(self, animationName, rotation)
	self:play_animation_internal(animationName, rotation, false);
end

AnimatedSprite.play_animation = function(self, animationName, rotation)
	local thread = self:play_animation_internal(animationName, rotation, true);
	assert(thread);
	return thread;
end

AnimatedSprite.play_animation_internal = function(self, animation_name, rotation, force_restart)
	local animation = self.spritesheet:animation(animation_name);
	assert(animation);
	local sequence = animation:sequence(rotation or math.pi / 2);
	assert(sequence);
	if sequence == self.sequence and not force_restart then
		return;
	end
	self.sequence = sequence;
	self.script:stop_all_threads();
	return self.script:run_thread(self:playback(animation, sequence));
end

---@private
---@param animation Animation
---@param sequence Sequence
AnimatedSprite.playback = function(self, animation, sequence)
	assert(animation);
	assert(sequence);
	local animator = self;
	return function(self)
		local start_time = self:time();
		local loop = animation:is_looping();
		local duration = sequence:duration();
		while true do
			local t = self:time() - start_time;
			t = loop and (t % duration) or math.min(t, duration);
			animator.keyframe = sequence:keyframe_at(t);
			animator:set_texture(animator.spritesheet:image());
			animator:set_quad(animator.keyframe.quad);
			animator:set_draw_offset(animator.keyframe.x, animator.keyframe.y);
			if t >= duration and not loop then
				break;
			else
				self:wait_frame();
			end
		end
	end;
end

--#region Tests

crystal.test.add("Set animation updates current frame", function()
	local sheet = crystal.assets.get("test-data/blankey.lua");
	local sprite = Sprite:new();
	local animator = AnimatedSprite:new(sprite, sheet);
	assert(not sprite:getFrame());
	animator:set_animation("hurt");
	assert(sprite:getFrame());
end);

crystal.test.add("Cycles through animation frames", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty.lua");
	local sheet = crystal.assets.get("test-data/blankey.lua");

	local entity = scene:spawn(crystal.Entity);
	local sprite = entity:add_component(Sprite);
	local animator = entity:add_component(AnimatedSprite, sprite, sheet);
	entity:add_component(crystal.ScriptRunner);

	animator:play_animation("floating");

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
	entity:add_component(AnimatedSprite, sprite, sheet);
	entity:add_component(crystal.ScriptRunner);

	local sentinel = false;
	entity:add_script(function(self)
		self:join(self:play_animation("hurt"));
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
	entity:add_component(AnimatedSprite, sprite, sheet);
	entity:add_component(crystal.ScriptRunner);

	local sentinel = false;
	entity:add_script(function(self)
		self:join(self:play_animation("floating"));
		sentinel = true;
	end);

	assert(not sentinel);
	scene:update(0.05);
	assert(not sentinel);
	scene:update(1000);
	assert(not sentinel);
end);

--#endregion

return AnimatedSprite;
