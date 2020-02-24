require("engine/utils/OOP");
local GFXConfig = require("engine/graphics/GFXConfig");
local Colors = require("engine/resources/Colors");

local CollisionMesh = Class("CollisionMesh");

CollisionMesh.init = function(self)
	self._chains = {};
end

CollisionMesh.addChain = function(self, chain)
	assert(chain);
	table.insert(self._chains, chain);
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
		love.graphics.setLineWidth(2);
		love.graphics.polygon("line", chain);
		love.graphics.setPointSize(6 * GFXConfig:getZoom());
		love.graphics.points(chain);
	end
end

CollisionMesh.getChains = function(self)
	return self._chains;
end

return CollisionMesh;
