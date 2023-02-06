local MeshBuilder = require("resources/map/MeshBuilder");

local tests = {};

tests[#tests + 1] = { name = "Single square" };
tests[#tests].body = function()
	local builder = MeshBuilder:new(50, 50, 10, 10, 4);
	builder:addPolygon(1, 1, { { 10, 10 }, { 20, 10 }, { 20, 20 }, { 10, 20 } });
	local collisionMesh = builder:buildMesh();
	assert(#collisionMesh:getChains() == 2);
end

tests[#tests + 1] = { name = "Simple merge" };
tests[#tests].body = function()
	local builder = MeshBuilder:new(50, 50, 10, 10, 4);
	builder:addPolygon(1, 1, { { 10, 10 }, { 20, 10 }, { 20, 20 }, { 10, 20 } });
	builder:addPolygon(2, 1, { { 20, 10 }, { 30, 10 }, { 30, 20 }, { 20, 20 } });
	builder:addPolygon(0, 0, { { 0, 0 }, { 5, 0 }, { 5, 5 }, { 0, 5 } });
	local collisionMesh = builder:buildMesh();
	assert(#collisionMesh:getChains() == 3);
end

return tests;
