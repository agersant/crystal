local angles = {
	East = math.rad(0),
	NorthEast = math.rad(-45),
	North = math.rad(-90),
	NorthWest = math.rad(-135),
	West = math.rad(180),
	SouthWest = math.rad(135),
	South = math.rad(90),
	SouthEast = math.rad(45),
};

crystal.assets.add_loader("lua", {
	can_load = function(path)
		local raw = require(path:strip_file_extension());
		return raw.crystal_spritesheet == true;
	end,
	dependencies = function(path)
		local raw = require(path:strip_file_extension());
		assert(type(raw.texture) == "string");
		return { raw.texture };
	end,
	load = function(path)
		local raw = require(path:strip_file_extension());
		local image = crystal.assets.get(raw.texture);
		local image_width, image_height = image:getDimensions();
		local spritesheet = crystal.Spritesheet:new(image);

		for name, raw_animation in pairs(raw.animations) do
			local animation = crystal.Animation:new(raw_animation.loop);
			spritesheet:add_animation(name, animation);
			for _, raw_sequence in ipairs(raw_animation.sequences) do
				local sequence = crystal.Sequence:new();
				local rotation = angles[raw_sequence.direction];
				assert(rotation);
				animation:add_sequence(rotation, sequence);
				for _, raw_keyframe in ipairs(raw_sequence.keyframes) do
					local frame = raw.frames[raw_keyframe.frame];
					assert(frame);
					local keyframe = {
						quad = love.graphics.newQuad(frame.x, frame.y, frame.w, frame.h, image_width, image_height),
						duration = raw_keyframe.duration,
						x = raw_keyframe.x,
						y = raw_keyframe.y,
						hitboxes = {},
					};
					if raw_keyframe.hitboxes then
						for name, raw_hitbox in pairs(raw_keyframe.hitboxes) do
							keyframe.hitboxes[name] = love.physics.newRectangleShape(
								raw_hitbox.rect.x + raw_hitbox.rect.w / 2,
								raw_hitbox.rect.y + raw_hitbox.rect.h / 2,
								raw_hitbox.rect.w,
								raw_hitbox.rect.h
							);
						end
					end
					sequence:add_keyframe(keyframe);
				end
			end
		end

		return spritesheet;
	end,
});

crystal.test.add("Can load a spritesheet", function()
	local spritesheet = crystal.assets.get("test-data/blankey.lua");
	assert(spritesheet);
	assert(spritesheet:inherits_from(crystal.Spritesheet));
	local animation = spritesheet:animation("hurt");
	local sequence = animation:sequence(0);
	local keyframe = sequence:keyframe_at(0);
	assert(keyframe.x);
	assert(keyframe.y);
	assert(keyframe.quad);
	assert(keyframe.duration);
	assert(keyframe.hitboxes["test"]);
end);
