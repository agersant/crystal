local json = require(CRYSTAL_RUNTIME .. "external/json")

local directions = {
	E = math.rad(0),
	NE = math.rad(-45),
	N = math.rad(-90),
	NW = math.rad(-135),
	W = math.rad(180),
	SW = math.rad(135),
	S = math.rad(90),
	SE = math.rad(45),
};

crystal.assets.add_loader("json", {
	can_load = function(path)
		local raw = love.filesystem.read(path);
		local decoded = json.decode(raw);
		return decoded.meta and decoded.meta.app == "http://www.aseprite.org/";
	end,
	dependencies = function(path)
		local raw = love.filesystem.read(path);
		local decoded = json.decode(raw);
		local image_path = path:parent_directory():merge_paths(decoded.meta.image);
		return { image_path };
	end,
	load = function(path)
		local raw = love.filesystem.read(path);
		local decoded = json.decode(raw);
		local image_path = path:parent_directory():merge_paths(decoded.meta.image);
		local image = crystal.assets.get(image_path);
		local image_width, image_height = image:getDimensions();
		local spritesheet = crystal.Spritesheet:new(image);

		if not table.is_array(decoded.frames) then
			error("Spritesheet '" .. path .. "' was exported from Aseprite with JSON data as Hash but should use Array instead.");
		end

		local tags_by_frame = {};

		for _, tag in pairs(decoded.meta.frameTags) do

			for frame = tag.from, tag.to do
				if not tags_by_frame[frame] then
					tags_by_frame[frame] = {};
				end
				table.insert(tags_by_frame[frame], tag);
			end

			local parent_tag = nil;
			if tags_by_frame[tag.from] then
				for _, overlapping_tag in ipairs(tags_by_frame[tag.from]) do
					if overlapping_tag.from <= tag.from and overlapping_tag.to >= tag.to then
						parent_tag = overlapping_tag;
					end
				end
			end

			local animation;
			local angle = 0;
			if directions[tag.name] ~= nil and parent_tag ~= nil then
				animation = spritesheet:animation(parent_tag.name);
				angle = directions[tag.name];
				assert(animation);
			else
				local num_repeat = tonumber(tag["repeat"]);
				local ping_pong = tag.direction:starts_with("pingpong");
				local reverse = tag.direction:ends_with("reverse");
				animation = crystal.Animation:new(num_repeat, ping_pong, reverse);
				spritesheet:add_animation(tag.name, animation);
			end

			local sequence = crystal.Sequence:new();
			animation:add_sequence(angle, sequence);
			for frame_index = tag.from, tag.to do
				local frame = decoded.frames[frame_index + 1];
				local pivot_x, pivot_y = math.round(frame.sourceSize.w / 2), math.round(frame.sourceSize.h / 2);
				local keyframe = {
					quad = love.graphics.newQuad(frame.frame.x, frame.frame.y, frame.frame.w, frame.frame.h, image_width, image_height),
					duration = frame.duration / 1000,
					x = -pivot_x,
					y = -pivot_y,
				};
				sequence:add_keyframe(keyframe);
			end
		end

		return spritesheet;
	end,
});

crystal.test.add("Can load a spritesheet", function()
	local spritesheet = crystal.assets.get("test-data/blankey.json");
	assert(spritesheet);
	assert(spritesheet:inherits_from(crystal.Spritesheet));
	local animation = spritesheet:animation("hurt");
	local sequence = animation:sequence(0);
	local keyframe = sequence:keyframe_at(0);
	assert(keyframe.x);
	assert(keyframe.y);
	assert(keyframe.quad);
	assert(keyframe.duration);
end);
