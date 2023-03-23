local Alias = require("utils/Alias");
local Colors = require("resources/Colors");
local Diamond = require("diamond");

---@class Map
---@field private width number
---@field private height number
---@field private tile_width number
---@field private tile_height number
---@field private _tilesets Tileset[]
---@field private tile_layers number[][]
---@field private gid_to_tileset { [number]: Tileset }
---@field private gid_to_tile_id { [number]: number }
---@field private gid_to_collision { [number]: Polygon[] }
---@field private entities { class: Class, x: number, y: number, options: table }[]
---@field private _mesh Mesh
local Map = Class("Map");

Map.init = function(self, width, height, tile_width, tile_height)
	assert(type(width) == "number");
	assert(type(height) == "number");
	self.width = width;
	self.height = height;
	self.tile_width = tile_width;
	self.tile_height = tile_height;
	self._tilesets = {};
	self.tile_layers = {};
	self.gid_to_tileset = {};
	self.gid_to_tile_id = {};
	self.gid_to_collision = {};
	self.entities = {};
	self._mesh = nil;
end

---@param first_gid number
---@param tileset Tileset
Map.add_tileset = function(self, first_gid, tileset)
	assert(type(first_gid) == "number");
	assert(tileset:inherits_from("Tileset"));
	table.push(self._tilesets, tileset);
	for i = 0, tileset:num_tiles() - 1 do
		self.gid_to_tileset[first_gid + i] = tileset;
		self.gid_to_tile_id[first_gid + i] = i;
		self.gid_to_collision[first_gid + i] = tileset:collision(i);
	end
end

---@param gids number[]
Map.add_tile_layer = function(self, gids)
	table.push(self.tile_layers, gids);
end

---@param class Class
---@param x number
---@param y number
---@param options table
Map.add_entity = function(self, class, x, y, options)
	assert(class);
	assert(type(x) == "number");
	assert(type(y) == "number");
	assert(type(options) == "table");
	options.x = x;
	options.y = y;
	table.push(self.entities, {
		x = x,
		y = y,
		class = class,
		options = options,
	});
end

Map.build_mesh = function(self)
	local navmesh_padding = 4.0;
	local builder = Diamond.new_mesh_builder(self.width, self.height, self.tile_width, self.tile_height, navmesh_padding);
	for id_offset, layer in ipairs(self.tile_layers) do
		for xy, gid in ipairs(layer) do
			local polygons = self.gid_to_collision[gid];
			if polygons then
				local tile_x, tile_y = math.index_to_xy(xy - 1, self.width);
				local x = tile_x * self.tile_width;
				local y = tile_y * self.tile_height;
				for _, polygon in ipairs(polygons) do
					local vertices = {};
					for _, vert in ipairs(polygon) do
						table.push(vertices, {
							x + math.round(vert.x),
							y + math.round(vert.y),
						});
					end
					builder:add_polygon(tile_x, tile_y, vertices);
				end
			end
		end
	end
	assert(not self._mesh);
	self._mesh = builder:build();
	Alias:add(self, self._mesh);
end

---@param ecs ECS
Map.spawn_entities = function(self, ecs)
	local map_entity = ecs:spawn(crystal.Entity);
	map_entity:add_component(crystal.Body, "static");

	local collision_polygons = self._mesh:collision_polygons();
	table.push(collision_polygons, {
		{ 0,                  0 },
		{ self:pixel_width(), 0 },
		{ self:pixel_width(), self:pixel_height() },
		{ 0,                  self:pixel_height() },
		{ 0,                  0 },
	});

	for _, obstacle in ipairs(collision_polygons) do
		local vertices = {};
		for _, vertex in ipairs(obstacle) do
			table.push(vertices, vertex[1]);
			table.push(vertices, vertex[2]);
		end
		table.pop(vertices);
		table.pop(vertices);
		local chain_shape = love.physics.newChainShape(true, vertices);
		local collider = map_entity:add_component(crystal.Collider, chain_shape);
		collider:set_categories("level");
		collider:enable_collision_with_everything();
	end

	for layer_index, layer in ipairs(self.tile_layers) do
		local batches = {};
		local quads = {};
		for _, tileset in ipairs(self._tilesets) do
			batches[tileset] = love.graphics.newSpriteBatch(tileset:image(), self.width * self.height, "static");
			quads[tileset] = love.graphics.newQuad(0, 0, 0, 0, tileset:image():getDimensions());
		end
		for xy, gid in ipairs(layer) do
			local tileset = self.gid_to_tileset[gid];
			local tile_id = self.gid_to_tile_id[gid];
			if tileset and tile_id then
				local batch = batches[tileset];
				local quad = quads[tileset];
				local tx, ty = math.index_to_xy(tile_id, tileset:tiles_per_row());
				quad:setViewport(
					tx * tileset:tile_width(),
					ty * tileset:tile_height(),
					tileset:tile_width(),
					tileset:tile_height()
				);
				local x, y = math.index_to_xy(xy - 1, self.width);
				x = x * self.tile_width;
				y = y * self.tile_height;
				batch:add(quad, x, y);
			end
		end
		for _, batch in pairs(batches) do
			if batch:getCount() > 0 then
				local drawable = map_entity:add_component("Drawable", batch);
				drawable:setZOrder(layer_index);
			end
		end
	end

	for _, entity in ipairs(self.entities) do
		xpcall(
			function()
				local spawned = ecs:spawn(entity.class, entity.options);
				local body = spawned:component(crystal.Body);
				if body then
					body:set_position(entity.x, entity.y);
				end
			end,
			function(err)
				crystal.log.error(
					"Error spawning map entity of class '" .. tostring(entity.class) .. "':\n" .. tostring(err)
				);
				print(debug.traceback());
			end
		);
	end

	return body;
end

Map._tilesets = function(self)
	return table.copy(self._tilesets);
end

Map.pixel_width = function(self)
	return self.width * self.tile_width;
end

Map.pixel_height = function(self)
	return self.height * self.tile_height;
end

return Map;
