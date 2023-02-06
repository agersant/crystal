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
	table.insert(self._vertices, x);
	table.insert(self._vertices, y);
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

return Path;
