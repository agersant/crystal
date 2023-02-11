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

--#region Tests


crystal.test.add("Basic usage", function()
	local From = Class:test("From");
	local To = Class:test("To");
	To.method = function()
		return true;
	end
	local from = From:new();
	local to = To:new();
	assert(not from.method);
	Alias:add(from, to);
	assert(from.method());
end);

crystal.test.add("Transitive", function()
	local From = Class:test("From");
	local Middle = Class:test("Middle");
	local To = Class:test("To");
	To.method = function()
		return true;
	end
	local from = From:new();
	local middle = Middle:new();
	local to = To:new();
	Alias:add(from, middle);
	Alias:add(middle, to);
	assert(from.method());
end);

crystal.test.add("Works for inherited methods", function()
	local From = Class:test("From");
	local Base = Class:test("Base");
	local To = Class:test("To", Base);
	Base.method = function()
		return true;
	end
	local from = From:new();
	local to = To:new();
	assert(not from.method);
	Alias:add(from, to);
	assert(from.method());
end);

-- TODO consider supporting this (doesnt break existing tests outside of this one) and also writing to existing aliased variables
crystal.test.add("Does not alias variables", function()
	local From = Class:test("From");
	local To = Class:test("To");
	local from = From:new();
	local to = To:new();
	to.member = true;
	Alias:add(from, to);
	assert(not from.member);
end);

crystal.test.add("Overrides self parameter", function()
	local From = Class:test("From");
	local To = Class:test("To");
	To.getMyClass = function(self)
		return self:class();
	end
	local from = From:new();
	local to = To:new();
	Alias:add(from, to);
	assert(from:getMyClass() == To);
end);

crystal.test.add("Errors on ambiguous call", function()
	local From = Class:test("From");
	local ToA = Class:test("ToA");
	local ToB = Class:test("ToB");
	ToA.example = function()
	end
	ToB.example = function()
	end
	local from = From:new();
	local toA = ToA:new();
	local toB = ToB:new();
	Alias:add(from, toA);
	Alias:add(from, toB);

	local success, errorMessage = pcall(function()
			from:example();
		end);
	assert(not success);
	assert(#errorMessage > 1);
end);

crystal.test.add("Shared base methods are not ambiguous", function()
	local From = Class:test("From");
	local Base = Class:test("Base");
	local DerivedA = Class:test("DerivedA", Base);
	local DerivedB = Class:test("DerivedB", Base);
	Base.example = function()
	end
	local from = From:new();
	local derivedA = DerivedA:new();
	local derivedB = DerivedB:new();
	Alias:add(from, derivedA);
	Alias:add(from, derivedB);

	local success = pcall(function()
			from:example();
		end);
	assert(success);
end);

--#endregion

return Alias;
