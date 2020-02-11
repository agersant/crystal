local MapCollisionMesh = require("engine/resources/map/MapCollisionMesh");

local tests = {};

tests[#tests + 1] = {name = "Load Beryl library"};
tests[#tests].body = function()
	local FFI = require("ffi");
	local Beryl = FFI.load("beryl");
end

tests[#tests + 1] = {name = "Load Navmesh Lua file"};
tests[#tests].body = function()
	local Navmesh = require("engine/ai/navmesh/Navmesh");
end

tests[#tests + 1] = {name = "Generate navmesh for empty map"};
tests[#tests].body = function()
	local Navmesh = require("engine/ai/navmesh/Navmesh");
	local collisionMesh = MapCollisionMesh:new(10, 10, 10);
	local navmesh = Navmesh:new(10, 10, collisionMesh, 0);
end

tests[#tests + 1] = {name = "Generate navmesh for empty map with padding"};
tests[#tests].body = function()
	local Navmesh = require("engine/ai/navmesh/Navmesh");
	local collisionMesh = MapCollisionMesh:new(10, 10, 10);
	local padding = 1;
	local navmesh = Navmesh:new(10, 10, collisionMesh, padding);
end

tests[#tests + 1] = {name = "Generate navmesh for empty map with extreme padding"};
tests[#tests].body = function()
	local Navmesh = require("engine/ai/navmesh/Navmesh");
	local collisionMesh = MapCollisionMesh:new(10, 10, 10);
	local padding = 20;
	local navmesh = Navmesh:new(10, 10, collisionMesh, padding);
end

tests[#tests + 1] = {name = "Find path in empty map"};
tests[#tests].body = function()
	local Navmesh = require("engine/ai/navmesh/Navmesh");
	local collisionMesh = MapCollisionMesh:new(10, 10, 10);
	local navmesh = Navmesh:new(10, 10, collisionMesh, 0);
	local path = navmesh:findPath(1, 2, 8, 9);
	assert(path:getNumVertices() == 2);
	for i, x, y in path:vertices() do
		assert(i ~= 1 or (x == 1 and y == 2));
		assert(i ~= 2 or (x == 8 and y == 9));
	end
end

tests[#tests + 1] = {name = "Find path from outside navmesh"};
tests[#tests].body = function()
	local Navmesh = require("engine/ai/navmesh/Navmesh");
	local collisionMesh = MapCollisionMesh:new(10, 10, 10);
	local navmesh = Navmesh:new(10, 10, collisionMesh, 0);
	local path = navmesh:findPath(-4, 2, 8, 9);
	assert(path:getNumVertices() == 3);
	for i, x, y in path:vertices() do
		assert(i ~= 1 or (x == -4 and y == 2));
		assert(i ~= 2 or (x == 0 and y == 2));
		assert(i ~= 3 or (x == 8 and y == 9));
	end
end

tests[#tests + 1] = {name = "Find path to outside navmesh"};
tests[#tests].body = function()
	local Navmesh = require("engine/ai/navmesh/Navmesh");
	local collisionMesh = MapCollisionMesh:new(10, 10, 10);
	local navmesh = Navmesh:new(10, 10, collisionMesh, 0);
	local path = navmesh:findPath(3, 5, 8, 14);
	assert(path:getNumVertices() == 2);
	for i, x, y in path:vertices() do
		assert(i ~= 1 or (x == 3 and y == 5));
		assert(i ~= 2 or (x == 8 and y == 10));
	end
end

tests[#tests + 1] = {name = "Project point on navmesh"};
tests[#tests].body = function()
	local Navmesh = require("engine/ai/navmesh/Navmesh");
	local collisionMesh = MapCollisionMesh:new(10, 10, 10);
	local navmesh = Navmesh:new(10, 10, collisionMesh, 0);
	local px, py = navmesh:getNearestPointOnNavmesh(-5, -5);
	assert(px == 0);
	assert(py == 0);
	local px, py = navmesh:getNearestPointOnNavmesh(5, -5);
	assert(px == 5);
	assert(py == 0);
end

return tests;
