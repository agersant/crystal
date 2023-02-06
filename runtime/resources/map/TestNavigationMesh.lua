local MeshBuilder = require("resources/map/MeshBuilder");
local tests = {};

tests[#tests + 1] = { name = "Generate navmesh for empty map" };
tests[#tests].body = function()
	local builder = MeshBuilder:new(50, 50, 10, 10, 0);
	local _, navigationMesh = builder:buildMesh();
	assert(navigationMesh);
end

tests[#tests + 1] = { name = "Generate navmesh for empty map with padding" };
tests[#tests].body = function()
	local builder = MeshBuilder:new(50, 50, 10, 10, 4);
	local _, navigationMesh = builder:buildMesh();
	assert(navigationMesh);
end

tests[#tests + 1] = { name = "Generate navmesh for empty map with extreme padding" };
tests[#tests].body = function()
	local padding = 20;
	local builder = MeshBuilder:new(50, 50, 10, 10, padding);
	local _, navigationMesh = builder:buildMesh();
	assert(navigationMesh);
end

tests[#tests + 1] = { name = "Find path in empty map" };
tests[#tests].body = function()
	local builder = MeshBuilder:new(50, 50, 10, 10, 4);
	local _, navigationMesh = builder:buildMesh();
	local success, path = navigationMesh:findPath(5, 8, 20, 30);
	assert(success);
	assert(path:getNumVertices() == 2);
	for i, x, y in path:vertices() do
		assert(i ~= 1 or (x == 5 and y == 8));
		assert(i ~= 2 or (x == 20 and y == 30));
	end
end

tests[#tests + 1] = { name = "Find path from outside navmesh" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Find path to outside navmesh" };
tests[#tests].body = function()
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
end

tests[#tests + 1] = { name = "Project point on navmesh" };
tests[#tests].body = function()
	local builder = MeshBuilder:new(10, 10, 16, 16, 0);
	local _, navigationMesh = builder:buildMesh();
	local px, py = navigationMesh:getNearestPointOnNavmesh(-5, -5);
	assert(px == 0);
	assert(py == 0);
	local px, py = navigationMesh:getNearestPointOnNavmesh(5, -5);
	assert(px == 5);
	assert(py == 0);
end

return tests;
