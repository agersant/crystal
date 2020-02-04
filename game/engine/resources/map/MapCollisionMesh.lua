require("engine/utils/OOP");
local Colors = require("engine/resources/Colors");
local MapCollisionChainData = require("engine/resources/map/MapCollisionChainData");
local MathUtils = require("engine/utils/MathUtils");

local MapCollisionMesh = Class("MapCollisionMesh");

-- IMPLEMENTATION

local mergeChains;
mergeChains = function(self)
	for a, chainA in ipairs(self._chains) do
		for b, chainB in ipairs(self._chains) do
			if a < b then
				if chainA:merge(chainB) then
					table.remove(self._chains, b);
					return mergeChains(self);
				end
			end
		end
	end
end

local addChain = function(self, newChain)
	for _, oldChain in ipairs(self._chains) do
		if oldChain:merge(newChain) then
			return;
		end
	end
	table.insert(self._chains, newChain);
end

-- PUBLIC API

MapCollisionMesh.init = function(self, widthInPixels, heightInPixels, heightInTiles)
	self._chains = {};
	self._activeTiles = {};
	for y = 0, heightInTiles - 1 do
		self._activeTiles[y] = {};
	end

	local edgesChain = MapCollisionChainData:new(true);
	edgesChain:addVertex(0, 0);
	edgesChain:addVertex(widthInPixels, 0);
	edgesChain:addVertex(widthInPixels, heightInPixels);
	edgesChain:addVertex(0, heightInPixels);
	addChain(self, edgesChain);
end

MapCollisionMesh.processLayer = function(self, tileset, layerData)

	local tileWidth = tileset:getTileWidth();
	local tileHeight = tileset:getTileHeight();

	for tileNum, tileID in ipairs(layerData.data) do
		local tileInfo = tileset:getTileData(tileID);
		if tileInfo then
			local tileX, tileY = MathUtils.indexToXY(tileNum - 1, layerData.width);
			if not self._activeTiles[tileY][tileX] then
				local x = tileX * tileWidth;
				local y = tileY * tileHeight;
				for polygonIndex, polygon in ipairs(tileInfo.collisionPolygons) do
					local chain = MapCollisionChainData:new(false);
					for vertIndex, vert in ipairs(polygon) do
						local vertX = MathUtils.round(vert.x);
						local vertY = MathUtils.round(vert.y);
						assert(vertX >= 0 and vertX <= tileWidth);
						assert(vertY >= 0 and vertY <= tileHeight);
						chain:addVertex(x + vertX, y + vertY);
					end
					addChain(self, chain);
					self._activeTiles[tileY][tileX] = true;
				end
			end
		end
	end

	mergeChains(self);
end

MapCollisionMesh.spawnBody = function(self, scene)
	local world = scene:getPhysicsWorld();
	local body = love.physics.newBody(world, 0, 0, "static");
	body:setUserData(self);
	for _, chain in ipairs(self._chains) do
		local fixture = love.physics.newFixture(body, chain:getShape());
		fixture:setFilterData(CollisionFilters.GEO, CollisionFilters.SOLID, 0);
	end
	return body;
end

MapCollisionMesh.draw = function(self)
	love.graphics.setColor(Colors.coquelicot);
	for _, chain in ipairs(self._chains) do
		chain:draw();
	end
end

MapCollisionMesh.chains = function(self)
	return ipairs(self._chains);
end

return MapCollisionMesh;
