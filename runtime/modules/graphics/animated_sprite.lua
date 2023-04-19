local Sprite = require("modules/graphics/sprite");

---@class AnimatedSprite : Sprite
---@field private script Script
---@field private spritesheet Spritesheet
---@field private sequence Sequence
---@field private keyframe Keyframe
local AnimatedSprite = Class("AnimatedSprite", Sprite);

AnimatedSprite.init = function(self, spritesheet)
	AnimatedSprite.super.init(self);
	assert(spritesheet:inherits_from("Spritesheet"));
	self.script = crystal.Script:new();
	self.spritesheet = spritesheet;
	self.sequence = nil;
	self.keyframe = nil;
end

AnimatedSprite.update_sprite_animation = function(self, dt)
	self.script:update(dt);
end

---@param name string
---@return love.Shape
AnimatedSprite.hitbox = function(self, name)
	if self.keyframe then
		return self.keyframe.hitboxes[name];
	end
end

AnimatedSprite.set_animation = function(self, animation_name, rotation)
	self:play_animation_internal(animation_name, rotation, false);
end

AnimatedSprite.play_animation = function(self, animation_name, rotation)
	local thread = self:play_animation_internal(animation_name, rotation, true);
	assert(thread);
	return thread;
end

AnimatedSprite.play_animation_internal = function(self, animation_name, rotation, force_restart)
	local animation = self.spritesheet:animation(animation_name);
	assert(animation);
	local sequence = animation:sequence(rotation or 0);
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
	local sprite = self;
	return function(self)
		local start_time = self:time();
		local loop = animation:is_looping();
		local duration = sequence:duration();
		while true do
			local t = self:time() - start_time;
			t = loop and (t % duration) or math.min(t, duration);
			sprite.keyframe = sequence:keyframe_at(t);
			sprite:set_texture(sprite.spritesheet:image());
			sprite:set_quad(sprite.keyframe.quad);
			sprite:set_draw_offset(sprite.keyframe.x, sprite.keyframe.y);
			if t >= duration and not loop then
				break;
			else
				self:wait_frame();
			end
		end
	end;
end

--#region Tests

local TestWorld = Class:test("TestWorld");

TestWorld.init = function(self)
	self.ecs = crystal.ECS:new();
	self.draw_system = self.ecs:add_system(crystal.DrawSystem);
	self.script_system = self.ecs:add_system(crystal.ScriptSystem);
end

TestWorld.update = function(self, dt)
	self.ecs:update(dt);
	self.script_system:run_scripts(dt);
	self.draw_system:update_drawables(dt);
end

crystal.test.add("Set animation updates current frame", function()
	local sheet = crystal.assets.get("test-data/blankey.lua");
	local sprite = AnimatedSprite:new(sheet);
	assert(not sprite.keyframe);
	sprite:set_animation("hurt");
	assert(sprite.keyframe);
end);

crystal.test.add("Cycles through animation frames", function()
	local world = TestWorld:new();
	local sheet = crystal.assets.get("test-data/blankey.lua");

	local entity = world.ecs:spawn(crystal.Entity);
	local sprite = entity:add_component(AnimatedSprite, sheet);

	sprite:play_animation("floating");
	local animation = sheet:animation("floating");
	local sequence = animation:sequence(0);
	assert(sequence:keyframe_at(0) ~= sequence:keyframe_at(0.5));

	for t = 0, 500 do
		assert(sprite.keyframe == sequence:keyframe_at((t * 1 / 60) % sequence:duration()));
		world:update(1 / 60);
	end
end);

crystal.test.add("Animation blocks script", function()
	local world = TestWorld:new();
	local sheet = crystal.assets.get("test-data/blankey.lua");

	local entity = world.ecs:spawn(crystal.Entity);
	entity:add_component(AnimatedSprite, sheet);
	entity:add_component(crystal.ScriptRunner);

	local sentinel = false;
	entity:add_script(function(self)
		self:play_animation("hurt"):block();
		sentinel = true;
	end);

	assert(not sentinel);
	world:update(0.05);
	assert(not sentinel);
	world:update(1);
	assert(sentinel);
end);

crystal.test.add("Looping animation thread never ends", function()
	local world = TestWorld:new();
	local sheet = crystal.assets.get("test-data/blankey.lua");

	local entity = world.ecs:spawn(crystal.Entity);
	entity:add_component(AnimatedSprite, sheet);
	entity:add_component(crystal.ScriptRunner);

	local sentinel = false;
	entity:add_script(function(self)
		self:play_animation("floating"):block();
		sentinel = true;
	end);

	assert(not sentinel);
	world:update(0.05);
	assert(not sentinel);
	world:update(1000);
	assert(not sentinel);
end);

--#endregion

return AnimatedSprite;
