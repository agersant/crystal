local MathUtils = require("utils/MathUtils");

-- Tileset loader
crystal.assets.add_loader("lua", {
	can_load = function(path)
		local raw = require(path:strip_file_extension());
		return raw.tiledversion and raw.tiles;
	end,
	dependencies = function(path)
		local raw = require(path:strip_file_extension());
		local image_path = path:parent_directory():merge_paths(raw.image);
		return { image_path };
	end,
	load = function(path)
		local raw = require(path:strip_file_extension());
		local image_path = path:parent_directory():merge_paths(raw.image);
		local image = crystal.assets.get(image_path);
		local tileset = crystal.Tileset:new(image, raw.tilewidth, raw.tileheight, raw.tilecount);

		for _, tile in ipairs(raw.tiles) do
			if tile.objectGroup and tile.objectGroup.objects then
				for _, object in ipairs(tile.objectGroup.objects) do
					if object.shape == "polygon" then
						local polygon = {};
						for _, vertex in ipairs(object.polygon) do
							local x = MathUtils.round(object.x + vertex.x);
							local y = MathUtils.round(object.y + vertex.y);
							table.push(polygon, { x = x, y = y });
						end
						tileset:add_collision(tile.id, polygon);
					end
					if object.shape == "rectangle" then
						local polygon = {};
						local x = MathUtils.round(object.x);
						local y = MathUtils.round(object.y);
						local w = MathUtils.round(object.width);
						local h = MathUtils.round(object.height);
						table.push(polygon, { x = x, y = y });
						table.push(polygon, { x = x + w, y = y });
						table.push(polygon, { x = x + w, y = y + h });
						table.push(polygon, { x = x, y = y + h });
						tileset:add_collision(tile.id, polygon);
					end
				end
			end
		end

		return tileset;
	end,
});

-- Map loader
crystal.assets.add_loader("lua", {
	can_load = function(path)
		local raw = require(path:strip_file_extension());
		return raw.tiledversion and raw.layers;
	end,
	dependencies = function(path)
		local raw = require(path:strip_file_extension());
		local deps = {};
		for _, tileset in ipairs(raw.tilesets) do
			if not tileset.exportfilename then
				local error_message = "Tileset (" ..
					tostring(tileset.filename) ..
					") has not been exported, or map (" .. tostring(path) .. ") needs to be re-exported.";
				error(error_message);
			end
			local tileset_path = path:parent_directory():merge_paths(tileset.exportfilename);
			table.push(deps, tileset_path);
		end
		return deps;
	end,
	load = function(path)
		local raw = require(path:strip_file_extension());
		local map = crystal.Map:new(raw.width, raw.height, raw.tilewidth, raw.tileheight);

		for _, tileset in ipairs(raw.tilesets) do
			local tileset_path = path:parent_directory():merge_paths(tileset.exportfilename);
			map:add_tileset(tileset.firstgid, crystal.assets.get(tileset_path));
		end

		for _, layer in ipairs(raw.layers) do
			if layer.type == "tilelayer" then
				map:add_tile_layer(layer.data);
			elseif layer.type == "objectgroup" then
				for _, object in ipairs(layer.objects) do
					assert(object.type);
					local class = Class:by_name(object.type);
					assert(class);
					local options = table.copy(object.properties);
					local x, y = object.x, object.y;
					if object.shape == "rectangle" then
						x = x + object.width / 2;
						y = y + object.height / 2;
						options.shape = love.physics.newRectangleShape(0, 0, object.width, object.height);
					end
					map:add_entity(class, x, y, options);
				end
			end
		end

		map:build_mesh();

		return map;
	end,
});

crystal.test.add("Can load an empty map", function()
	local map = crystal.assets.get("test-data/empty.lua");
	assert(map)
	assert(map:inherits_from(crystal.Map));
end);