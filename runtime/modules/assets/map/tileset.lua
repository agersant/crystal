---@class Tileset
---@field private _image love.Image
---@field private _tile_width number
---@field private _tile_height number
---@field private _tiles_per_row number
---@field private _num_tiles number
---@field private _collision { [number]: { x: number, y: number }[][] }
local Tileset = Class("Tileset");

Tileset.init = function(self, image, tile_width, tile_height, num_tiles)
	assert(image:typeOf("Image"));
	assert(type(tile_width) == "number");
	assert(type(tile_height) == "number");
	assert(type(num_tiles) == "number");
	local image_width, _ = image:getDimensions();
	self._image = image;
	self._tile_width = tile_width;
	self._tile_height = tile_height;
	self._tiles_per_row = math.floor(image_width / tile_width);
	self._collision = {};
	self._num_tiles = num_tiles;
end

---@param tile_id number
---@param polygon { x: number, y: number }[]
Tileset.add_collision = function(self, tile_id, polygon)
	if not self._collision[tile_id] then
		self._collision[tile_id] = {};
	end
	table.push(self._collision[tile_id], polygon);
end

---@return { x: number, y: number }[][]
Tileset.collision = function(self, tile_id)
	return self._collision[tile_id];
end

---@return love.Image
Tileset.image = function(self)
	return self._image;
end

---@return number
Tileset.tile_width = function(self)
	return self._tile_width;
end

---@return number
Tileset.tile_height = function(self)
	return self._tile_height;
end

---@return number
Tileset.tiles_per_row = function(self)
	return self._tiles_per_row;
end

---@return number
Tileset.num_tiles = function(self)
	return self._num_tiles;
end

return Tileset;
