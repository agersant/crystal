local Features = require("dev/Features");
local TableUtils = require("utils/TableUtils");

local Alias = {};

local search;

if not Features.slowAssertions then

	search = function(originalIndex)
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
				end
			end
		end
	end

else

	search = function(originalIndex)
		return function(from, key)
			local value = originalIndex[key];
			if value then
				return value;
			end

			if not rawget(from, "__aliases") then
				return nil;
			end

			local results = {};
			for alias in pairs(from.__aliases) do
				local value = alias[key];
				if value and type(value) == "function" then
					local result = {
						alias = alias,
						wrappedMethod = function(from, ...)
							return value(alias, ...);
						end,
					};
					results[value] = result;
				end
			end

			local numResults = TableUtils.countKeys(results);
			if numResults > 1 then
				local errorMessage = string.format("Ambiguous method call, %s.%s can resolve to any of the followings:",
					from:getClassName(), key);
				for _, result in ipairs(results) do
					errorMessage = errorMessage .. string.format("\n\t- %s.%s", result.alias:getClassName(), key);
				end
				error(errorMessage);
			elseif numResults == 1 then
				for _, result in pairs(results) do
					return result.wrappedMethod;
				end
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
