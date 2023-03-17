local Diamond = require("diamond");
local CollisionMesh = require("resources/map/CollisionMesh");
local NavigationMesh = require("resources/map/NavigationMesh");
local MathUtils = require("utils/MathUtils");

local MeshBuilder = Class("MeshBuilder");

MeshBuilder.init = function(self, width, height, tileWidth, tileHeight, navigationPadding)
	assert(width);
	assert(width > 0);
	assert(height);
	assert(height > 0);
	assert(tileWidth);
	assert(tileWidth > 0);
	assert(tileHeight);
	assert(tileHeight > 0);
	assert(navigationPadding >= 0);
	self._w = width * tileWidth;
	self._h = height * tileHeight;
	self._builder = Diamond.newMeshBuilder(width, height, tileWidth, tileHeight, navigationPadding);
	assert(self._builder);
end

MeshBuilder.addPolygon = function(self, tileX, tileY, vertices)
	assert(self._builder);
	self._builder:addPolygon(tileX, tileY, vertices);
end

MeshBuilder.addLayer = function(self, tileset, layerData)
	assert(self._builder);
	local tileWidth = tileset:getTileWidth();
	local tileHeight = tileset:getTileHeight();
	for tileNum, tileID in ipairs(layerData.data) do
		local tileInfo = tileset:getTileData(tileID);
		if tileInfo then
			local tileX, tileY = MathUtils.indexToXY(tileNum - 1, layerData.width);
			local x = tileX * tileWidth;
			local y = tileY * tileHeight;
			for _, localPolygon in ipairs(tileInfo.collisionPolygons) do
				local polygon = {};
				for _, vert in ipairs(localPolygon) do
					local vertX = MathUtils.round(vert.x);
					local vertY = MathUtils.round(vert.y);
					table.push(polygon, { x + vertX, y + vertY });
				end
				self:addPolygon(tileX, tileY, polygon);
			end
		end
	end
end

MeshBuilder.buildMesh = function(self)
	assert(self._builder);
	local mesh = self._builder:buildMesh();
	self._builder = nil;
	local collisionMesh = CollisionMesh:new(self._w, self._h, mesh);
	local navigationMesh = NavigationMesh:new(mesh);
	return collisionMesh, navigationMesh;
end

--#region Tests

crystal.test.add("Single square", function()
	local builder = MeshBuilder:new(50, 50, 10, 10, 4);
	builder:addPolygon(1, 1, { { 10, 10 }, { 20, 10 }, { 20, 20 }, { 10, 20 } });
	local collisionMesh = builder:buildMesh();
	assert(#collisionMesh:getChains() == 2);
end);

crystal.test.add("Simple merge", function()
	local builder = MeshBuilder:new(50, 50, 10, 10, 4);
	builder:addPolygon(1, 1, { { 10, 10 }, { 20, 10 }, { 20, 20 }, { 10, 20 } });
	builder:addPolygon(2, 1, { { 20, 10 }, { 30, 10 }, { 30, 20 }, { 20, 20 } });
	builder:addPolygon(0, 0, { { 0, 0 }, { 5, 0 }, { 5, 5 }, { 0, 5 } });
	local collisionMesh = builder:buildMesh();
	assert(#collisionMesh:getChains() == 3);
end);


crystal.test.add("Generate navmesh for empty map", function()
	local builder = MeshBuilder:new(50, 50, 10, 10, 0);
	local _, navigationMesh = builder:buildMesh();
	assert(navigationMesh);
end);

crystal.test.add("Generate navmesh for empty map with padding", function()
	local builder = MeshBuilder:new(50, 50, 10, 10, 4);
	local _, navigationMesh = builder:buildMesh();
	assert(navigationMesh);
end);

crystal.test.add("Generate navmesh for empty map with extreme padding", function()
	local padding = 20;
	local builder = MeshBuilder:new(50, 50, 10, 10, padding);
	local _, navigationMesh = builder:buildMesh();
	assert(navigationMesh);
end);

crystal.test.add("Find path in empty map", function()
	local builder = MeshBuilder:new(50, 50, 10, 10, 4);
	local _, navigationMesh = builder:buildMesh();
	local success, path = navigationMesh:findPath(5, 8, 20, 30);
	assert(success);
	assert(path:getNumVertices() == 2);
	for i, x, y in path:vertices() do
		assert(i ~= 1 or (x == 5 and y == 8));
		assert(i ~= 2 or (x == 20 and y == 30));
	end
end);

crystal.test.add("Find path from outside navmesh", function()
	local builder = MeshBuilder:new(50, 50, 10, 10, 0);
	local _, navigationMesh = builder:buildMesh();
	local success, path = navigationMesh:findPath(-4, 2, 8, 9);
	assert(success);
	assert(path:getNumVertices() == 3);
	for i, x, y in path:vertices() do
		assert(i ~= 1 or (x == -4 and y == 2));
		assert(i ~= 2 or (x == 0 and y == 2));
		assert(i ~= 3 or (x == 8 and y == 9));
	end
end);

crystal.test.add("Find path to outside navmesh", function()
	local builder = MeshBuilder:new(1, 1, 10, 10, 0);
	local _, navigationMesh = builder:buildMesh();
	local success, path = navigationMesh:findPath(3, 5, 8, 14);
	assert(success);
	assert(path:getNumVertices() == 3);
	for i, x, y in path:vertices() do
		assert(i ~= 1 or (x == 3 and y == 5));
		assert(i ~= 2 or (x == 8 and y == 10));
		assert(i ~= 3 or (x == 8 and y == 14));
	end
end);

crystal.test.add("Project point on navmesh", function()
	local builder = MeshBuilder:new(10, 10, 16, 16, 0);
	local _, navigationMesh = builder:buildMesh();
	local px, py = navigationMesh:getNearestPointOnNavmesh(-5, -5);
	assert(px == 0);
	assert(py == 0);
	local px, py = navigationMesh:getNearestPointOnNavmesh(5, -5);
	assert(px == 5);
	assert(py == 0);
end);

--#endregion

return MeshBuilder;
