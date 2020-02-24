local CollisionMeshBuilder = require("engine/resources/map/collision/CollisionMeshBuilder");

local tests = {};

tests[#tests + 1] = {name = "Load Diamond library"};
tests[#tests].body = function()
	require("engine/ffi/Diamond");
	local FFI = require("ffi");
	local Diamond = FFI.load("diamond");
end

tests[#tests + 1] = {name = "Single square"};
tests[#tests].body = function()
	local builder = CollisionMeshBuilder:new(50, 50);
	builder:addPolygon({{x = 10, y = 10}, {x = 20, y = 10}, {x = 20, y = 20}, {x = 10, y = 20}});
	local mesh = builder:buildMesh();
	assert(#mesh:getChains() == 1);
end

tests[#tests + 1] = {name = "Simple merge"};
tests[#tests].body = function()
	local builder = CollisionMeshBuilder:new(50, 50);
	builder:addPolygon({{x = 10, y = 10}, {x = 20, y = 10}, {x = 20, y = 20}, {x = 10, y = 20}});
	builder:addPolygon({{x = 20, y = 10}, {x = 30, y = 10}, {x = 30, y = 20}, {x = 20, y = 20}});
	builder:addPolygon({{x = 0, y = 0}, {x = 5, y = 0}, {x = 5, y = 5}, {x = 0, y = 5}});
	local mesh = builder:buildMesh();
	assert(#mesh:getChains() == 2);
end

return tests;
