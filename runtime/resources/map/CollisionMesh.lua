local Colors = require("resources/Colors");

local CollisionMesh = Class("CollisionMesh");

local addChain = function(self, chain)
	assert(chain);
	table.insert(self._chains, chain);
	return chain;
end

CollisionMesh.init = function(self, mapWidth, mapHeight, mesh)
	assert(mapWidth);
	assert(mapHeight);
	assert(mesh);

	self._chains = {};
	for _, obstacle in ipairs(mesh:listCollisionPolygons()) do
		local chain = {};
		for _, vertex in ipairs(obstacle) do
			table.insert(chain, vertex[1]);
			table.insert(chain, vertex[2]);
		end
		table.remove(chain, #chain);
		table.remove(chain, #chain);
		addChain(self, chain);
	end

	self._outerChain = addChain(self, { 0, 0, mapWidth, 0, mapWidth, mapHeight, 0, mapHeight });
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

CollisionMesh.draw = function(self, viewport)
	love.graphics.setColor(Colors.redOrange);
	love.graphics.setLineWidth(2);
	love.graphics.setLineJoin("bevel");
	love.graphics.setPointSize(6 * viewport:getZoom());
	for _, chain in ipairs(self._chains) do
		if #chain >= 6 then
			love.graphics.polygon("line", chain);
			love.graphics.points(chain);
		end
	end
end

CollisionMesh.getChains = function(self)
	return self._chains;
end

return CollisionMesh;
