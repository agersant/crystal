require("engine/utils/OOP");
local FFI = require("ffi");
local Diamond = FFI.load("diamond");
local GFXConfig = require("engine/graphics/GFXConfig");
local Colors = require("engine/resources/Colors");

local CollisionMesh = Class("CollisionMesh");

local newPolygons = function()
	local output = FFI.gc(Diamond.polygons_new(), function(polygons)
		Diamond.polygons_delete(polygons);
	end);
	return output;
end

local addChain = function(self, chain)
	assert(chain);
	table.insert(self._chains, chain);
	return chain;
end

CollisionMesh.init = function(self, mapWidth, mapHeight, cMesh)
	assert(mapWidth);
	assert(mapHeight);
	assert(cMesh);

	self._chains = {};
	local obstacles = newPolygons();
	Diamond.mesh_list_collision_polygons(cMesh, obstacles);
	for chainIndex = 0, obstacles.num_polygons - 1 do
		local chain = {};
		local cPolygon = obstacles.polygons[chainIndex];
		for i = 0, cPolygon.num_vertices - 2 do
			local cVertex = cPolygon.vertices[i];
			table.insert(chain, cVertex.x);
			table.insert(chain, cVertex.y);
		end
		addChain(self, chain);
	end

	self._outerChain = addChain(self, {0, 0, mapWidth, 0, mapWidth, mapHeight, 0, mapHeight});
end

CollisionMesh.isOuterEdge = function(self, chain)
	return chain == self._outerChain;
end

CollisionMesh.spawnBody = function(self, scene)
	local world = scene:getPhysicsWorld();
	local body = love.physics.newBody(world, 0, 0);
	body:setUserData(self);
	for _, chain in ipairs(self._chains) do
		local shape = love.physics.newChainShape(true, chain);
		local fixture = love.physics.newFixture(body, shape, 0);
		fixture:setFilterData(CollisionFilters.GEO, CollisionFilters.SOLID, 0);
	end
	return body;
end

CollisionMesh.draw = function(self)
	love.graphics.setColor(Colors.coquelicot);
	for _, chain in ipairs(self._chains) do
		if #chain >= 6 then
			love.graphics.setLineWidth(2);
			love.graphics.polygon("line", chain);
			love.graphics.setPointSize(6 * GFXConfig:getZoom());
			love.graphics.points(chain);
		end
	end
end

CollisionMesh.getChains = function(self)
	return self._chains;
end

return CollisionMesh;
