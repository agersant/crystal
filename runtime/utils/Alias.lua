local features = require("features");

local Alias = {};

local find_method;

find_method = function(index)
	return function(from, key)
		local value = index[key];
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

if features.slow_assertions then
	find_method = function(index)
		return function(from, key)
			local value = index[key];
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
						method = function(from, ...)
							return value(alias, ...);
						end,
					};
					results[alias] = result;
				end
			end

			local num_results = table.count(results);
			if num_results > 1 then
				local message = string.format("Ambiguous method call, %s.%s can resolve to any of the followings:",
					from:class_name(), key);
				for _, result in pairs(results) do
					message = message .. string.format("\n\t- %s.%s", result.alias:class_name(), key);
				end
				error(message);
			elseif num_results == 1 then
				for _, result in pairs(results) do
					return result.method;
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
	assert(metatable and metatable.__index);
	if type(metatable.__index) == "table" then
		metatable.__index = find_method(metatable.__index);
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

	local success, message = pcall(function()
		from:example();
	end);
	assert(not success);
	assert(#message > 1);
end);

crystal.test.add("Errors on ambiguous call to same method", function()
	local From = Class:test("From");
	local To = Class:test("To");
	To.example = function()
	end
	local from = From:new();
	local toA = To:new();
	local toB = To:new();
	Alias:add(from, toA);
	Alias:add(from, toB);

	local success, message = pcall(function()
		from:example();
	end);
	assert(not success);
	assert(#message > 1);
end);

--#endregion

return Alias;
