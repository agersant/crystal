local Path = require("mapscene/behavior/ai/Path");

local tests = {};

tests[#tests + 1] = { name = "Count vertices" };
tests[#tests].body = function()
	local path = Path:new();
	assert(path:getNumVertices() == 0);
	path:addVertex(0, 10);
	path:addVertex(1, 20);
	path:addVertex(2, 30);
	assert(path:getNumVertices() == 3);
end

tests[#tests + 1] = { name = "Iterate on vertices" };
tests[#tests].body = function()
	local path = Path:new();
	path:addVertex(0, 10);
	path:addVertex(1, 20);
	path:addVertex(2, 30);
	local iterated = 0;
	for i, x, y in path:vertices() do
		assert(i ~= 1 or (x == 0 and y == 10));
		assert(i ~= 2 or (x == 1 and y == 20));
		assert(i ~= 3 or (x == 2 and y == 30));
		iterated = iterated + 1;
	end
	assert(iterated == 3);
end

return tests;
