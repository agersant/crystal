local Path = Class("Path");

local getVertex = function(self, i)
	return self._vertices[2 * i - 1], self._vertices[2 * i];
end

local vertexIter = function(self, i)
	local numVertices = self:getNumVertices();
	i = i + 1;
	if i > numVertices then
		return nil;
	end
	local x, y = getVertex(self, i);
	return i, x, y;
end

Path.init = function(self)
	self._vertices = {};
end

Path.addVertex = function(self, x, y)
	table.push(self._vertices, x);
	table.push(self._vertices, y);
end

Path.getVertex = function(self, index)
	local i = 1 + (index - 1) * 2;
	return self._vertices[i], self._vertices[i + 1];
end

Path.vertices = function(self)
	return vertexIter, self, 0;
end

Path.getNumVertices = function(self)
	return #self._vertices / 2;
end

--#region Tests

crystal.test.add("Count vertices", function()
	local path = Path:new();
	assert(path:getNumVertices() == 0);
	path:addVertex(0, 10);
	path:addVertex(1, 20);
	path:addVertex(2, 30);
	assert(path:getNumVertices() == 3);
end);

crystal.test.add("Iterate on vertices", function()
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
end);

--#endregion

return Path;
