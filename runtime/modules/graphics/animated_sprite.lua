local Sprite = require(CRYSTAL_RUNTIME .. "modules/graphics/sprite");

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

AnimatedSprite.set_animation = function(self, animation_name, sequence_name)
	self:play_animation_internal(animation_name, sequence_name, false);
end

AnimatedSprite.play_animation = function(self, animation_name, sequence_name)
	local thread = self:play_animation_internal(animation_name, sequence_name, true);
	assert(thread);
	return thread;
end

AnimatedSprite.play_animation_internal = function(self, animation_name, sequence_name, force_restart)
	local animation = self.spritesheet:animation(animation_name);
	assert(animation);
	local sequence = animation:sequence(sequence_name);
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
		local num_repeat = animation:num_repeat();
		local ping_pong = animation:is_ping_pong();
		local reverse = animation:is_reversed();
		local duration = sequence:duration();
		while true do
			local clock = self:time() - start_time;
			local loops_played;
			local t;

			if not ping_pong then
				loops_played = math.floor(clock / duration);
				if num_repeat == nil or loops_played < num_repeat then
					t = clock % duration;
				else
					t = duration;
				end
				if reverse then
					t = duration - t;
				end
			else
				local first_duration = sequence:keyframe_at(0).duration;
				local last_duration = sequence:keyframe_at(math.huge).duration;
				local cycle_duration = 2 * duration - first_duration - last_duration;
				
				if reverse then
					loops_played = 2 * math.floor(clock / (2 * duration - first_duration)) + math.floor((clock % cycle_duration) / duration);
				else
					loops_played = 2 * math.floor(clock / (2 * duration - last_duration)) + math.floor((clock % cycle_duration) / duration);
				end

				if num_repeat == nil or loops_played < num_repeat then
					t = clock % cycle_duration;
				else
					t = num_repeat % 2 == 1 and duration or 0;
				end

				if reverse then					
					if t >= duration then
						t = (duration - first_duration) - (t - duration);
					end
					t = duration - t;
				else
					if t >= duration then
						t = (duration - last_duration) - (t - duration);
					end
				end
			end

			sprite.keyframe = sequence:keyframe_at(t);
			sprite:set_texture(sprite.spritesheet:image());
			sprite:set_quad(sprite.keyframe.quad);

			if num_repeat and loops_played >= num_repeat then
				break;
			else
				self:wait_frame();
			end
		end
	end;
end

AnimatedSprite.draw = function(self)
	if not self.keyframe then
		return;
	end
	love.graphics.push();
	love.graphics.translate(self.keyframe.x, self.keyframe.y);
	AnimatedSprite.super.draw(self);
	love.graphics.pop();
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
	local sheet = crystal.assets.get("test-data/blankey.json");
	local sprite = AnimatedSprite:new(sheet);
	assert(not sprite.keyframe);
	sprite:set_animation("hurt");
	assert(sprite.keyframe);
end);

crystal.test.add("Cycles through animation frames", function()
	local world = TestWorld:new();
	local sheet = crystal.assets.get("test-data/blankey.json");

	local entity = world.ecs:spawn(crystal.Entity);
	local sprite = entity:add_component(AnimatedSprite, sheet);

	sprite:play_animation("floating");
	local animation = sheet:animation("floating");
	local sequence = animation:sequence();
	assert(sequence:keyframe_at(0) ~= sequence:keyframe_at(0.2));

	local t = 0;
	local dt = 1 / 60;
	for i = 0, 500 do
		assert(sprite.keyframe == sequence:keyframe_at(t  % sequence:duration()));
		world:update(dt);
		t = t + dt;
	end
end);

crystal.test.add("Animation repeats the right number of times", function()
	local world = TestWorld:new();
	local sheet = crystal.assets.get("test-data/playback-options.json");
	local sequence = sheet:animation("repeat"):sequence();

	local entity = world.ecs:spawn(crystal.Entity);
	local sprite = entity:add_component(AnimatedSprite, sheet);
	entity:play_animation("repeat");

	assert(sprite.keyframe == sequence:keyframe_at(0));
	world:update(0.1);
	assert(sprite.keyframe == sequence:keyframe_at(0.1));
	world:update(0.5);
	assert(sprite.keyframe == sequence:keyframe_at(0.4));
end);

crystal.test.add("Animation can play in reverse", function()
	local world = TestWorld:new();
	local sheet = crystal.assets.get("test-data/playback-options.json");
	local sequence = sheet:animation("reverse"):sequence();

	local entity = world.ecs:spawn(crystal.Entity);
	local sprite = entity:add_component(AnimatedSprite, sheet);
	entity:play_animation("reverse");

	assert(sprite.keyframe == sequence:keyframe_at(0.31));
	world:update(0.11);
	assert(sprite.keyframe == sequence:keyframe_at(0.21));
	world:update(0.1);
	assert(sprite.keyframe == sequence:keyframe_at(0.11));
	world:update(0.1);
	assert(sprite.keyframe == sequence:keyframe_at(0.01));
	world:update(0.1);
	assert(sprite.keyframe == sequence:keyframe_at(0.31));
end);

crystal.test.add("Animation can ping-pong", function()
	local world = TestWorld:new();
	local sheet = crystal.assets.get("test-data/playback-options.json");
	local sequence = sheet:animation("pingpong"):sequence();

	local entity = world.ecs:spawn(crystal.Entity);
	local sprite = entity:add_component(AnimatedSprite, sheet);
	entity:play_animation("pingpong");

	assert(sprite.keyframe == sequence:keyframe_at(0));
	world:update(0.11);
	assert(sprite.keyframe == sequence:keyframe_at(0.11));
	world:update(0.1);
	assert(sprite.keyframe == sequence:keyframe_at(0.21));
	world:update(0.1);
	assert(sprite.keyframe == sequence:keyframe_at(0.31));
	world:update(0.11);
	assert(sprite.keyframe == sequence:keyframe_at(0.21));
	world:update(0.1);
	assert(sprite.keyframe == sequence:keyframe_at(0.11));
	world:update(0.1);
	assert(sprite.keyframe == sequence:keyframe_at(0.01));
	world:update(0.1);
	assert(sprite.keyframe == sequence:keyframe_at(0.11));
end);

crystal.test.add("Animation can ping-pong reverse", function()
	local world = TestWorld:new();
	local sheet = crystal.assets.get("test-data/playback-options.json");
	local sequence = sheet:animation("pingpong-reverse"):sequence();

	local entity = world.ecs:spawn(crystal.Entity);
	local sprite = entity:add_component(AnimatedSprite, sheet);
	entity:play_animation("pingpong-reverse");

	assert(sprite.keyframe == sequence:keyframe_at(0.31));
	world:update(0.11);
	assert(sprite.keyframe == sequence:keyframe_at(0.21));
	world:update(0.1);
	assert(sprite.keyframe == sequence:keyframe_at(0.11));
	world:update(0.1);
	assert(sprite.keyframe == sequence:keyframe_at(0.01));
	world:update(0.11);
	assert(sprite.keyframe == sequence:keyframe_at(0.11));
	world:update(0.1);
	assert(sprite.keyframe == sequence:keyframe_at(0.21));
	world:update(0.1);
	assert(sprite.keyframe == sequence:keyframe_at(0.31));
	world:update(0.1);
	assert(sprite.keyframe == sequence:keyframe_at(0.21));
end);

crystal.test.add("Animation can ping-pong reverse repeat", function()
	local world = TestWorld:new();
	local sheet = crystal.assets.get("test-data/playback-options.json");
	local sequence = sheet:animation("pingpong-reverse-repeat"):sequence();

	local entity = world.ecs:spawn(crystal.Entity);
	local sprite = entity:add_component(AnimatedSprite, sheet);
	entity:play_animation("pingpong-reverse-repeat");

	assert(sprite.keyframe == sequence:keyframe_at(0.31));
	world:update(0.11);
	assert(sprite.keyframe == sequence:keyframe_at(0.21));
	world:update(0.1);
	assert(sprite.keyframe == sequence:keyframe_at(0.11));
	world:update(0.1);
	assert(sprite.keyframe == sequence:keyframe_at(0.01));
	world:update(0.11);
	assert(sprite.keyframe == sequence:keyframe_at(0.11));
	world:update(0.1);
	assert(sprite.keyframe == sequence:keyframe_at(0.21));
	world:update(0.1);
	assert(sprite.keyframe == sequence:keyframe_at(0.31));
	world:update(0.1);
	assert(sprite.keyframe == sequence:keyframe_at(0.31));
	world:update(0.1);
	assert(sprite.keyframe == sequence:keyframe_at(0.31));
end);

crystal.test.add("Animation blocks script", function()
	local world = TestWorld:new();
	local sheet = crystal.assets.get("test-data/blankey.json");

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
	local sheet = crystal.assets.get("test-data/blankey.json");

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
