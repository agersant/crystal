local Alias = {};

local search = function(originalIndex)
	return function(from, key)
		local value = originalIndex[key];
		if value then
			return value;
		end
		if rawget(from, "__aliases") then
			for alias in pairs(from.__aliases) do
				local value = alias[key];
				if value and type(value) == "function" then
					return function(from, ...)
						return value(alias, ...);
					end
				end
				-- TODO assert against multiple matches with distinct values
			end
		end
	end
end

Alias.add = function(self, from, to)
	if not from.__aliases then
		from.__aliases = {};
	end
	local metatable = getmetatable(from);
	if type(metatable.__index) == "table" then
		metatable.__index = search(metatable.__index);
	end
	assert(not from.__aliases[to]);
	from.__aliases[to] = true;
end

Alias.remove = function(self, from, to)
	assert(from.__aliases);
	assert(from.__aliases[to]);
	from.__aliases[to] = nil;
end

return Alias;
