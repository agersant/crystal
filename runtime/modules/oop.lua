local features = require(CRYSTAL_RUNTIME .. "/features");

local all_classes = {};

local get_class_by_name = function(_, name)
	return all_classes[name];
end

local object_in_place_constructor = function(class, obj, ...)
	setmetatable(obj, class._obj_metatable);
	if obj.init then
		obj:init(...);
	end
	return obj;
end

local object_constructor = function(class, ...)
	local obj = {};
	return object_in_place_constructor(class, obj, ...);
end

local make_inherits_from = function(class)
	return function(self, other_class)
		if type(other_class) == "string" then
			other_class = all_classes[other_class];
		end
		assert(other_class);
		if class == other_class then
			return true;
		end
		if self.super then
			return self.super.inherits_from(self.super, other_class);
		end
		return false;
	end
end

local get_class = function(self)
	return self._class;
end

local get_class_name = function(self)
	return self._class._name;
end

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

local make_add_alias = function(class)
	local find = find_method(class);
	return function(from, to)
		if not from.__aliases then
			from.__aliases = {};
		end
		local metatable = getmetatable(from);
		assert(metatable);
		metatable.__index = find;
		assert(not from.__aliases[to]);
		from.__aliases[to] = true;
	end
end

local remove_alias = function(from, to)
	assert(from.__aliases);
	assert(from.__aliases[to]);
	from.__aliases[to] = nil;
end

local declare_class = function(self, name, base_class, options)
	local class_metatable = {};
	class_metatable.__index = base_class;
	class_metatable.__tostring = function(class)
		return "Class definition of: " .. class._name;
	end
	local class = setmetatable({}, class_metatable);

	local obj_metatable = {};
	obj_metatable.__index = class;
	obj_metatable.__tostring = function(obj)
		return "Instance of class: " .. obj._class._name;
	end

	class._class = class;
	class._name = name;
	class._obj_metatable = obj_metatable;

	class.super = base_class;
	class.new = object_constructor;
	class.placement_new = object_in_place_constructor;
	class.class = get_class;
	class.class_name = get_class_name;
	class.inherits_from = make_inherits_from(class);
	class.add_alias = make_add_alias(class);
	class.remove_alias = remove_alias;

	local allow_redefinition = options and options.allow_redefinition;
	if not allow_redefinition then
		assert(not all_classes[name]);
	end
	all_classes[name] = class;

	return class;
end

Class = setmetatable({}, { __call = declare_class });
Class.by_name = get_class_by_name;
Class.test = function(self, name, base_class)
	return declare_class(self, name, base_class, { allow_redefinition = true });
end

return {
	start = function()
		--#region Tests

		crystal.test.add("Classes implement tostring", function()
			local Fruit = Class:test("Fruit");
			local Peach = Class:test("Peach", Fruit);
			local Bird = Class:test("Bird");
			assert(tostring(Fruit));
			assert(#tostring(Fruit) > 0);
			assert(tostring(Fruit) ~= tostring(Bird));
			assert(tostring(Fruit) ~= tostring(Peach));
		end);

		crystal.test.add("Can get class from object", function()
			local Fruit = Class:test("Fruit");
			local Peach = Class:test("Peach", Fruit);
			local my_fruit = Fruit:new();
			local my_peach = Peach:new();
			assert(my_fruit:class() == Fruit);
			assert(my_peach:class() == Peach);
		end);

		crystal.test.add("Can get class name", function()
			local Fruit = Class:test("Fruit");
			local Peach = Class:test("Peach", Fruit);
			local my_fruit = Fruit:new();
			local my_peach = Peach:new();
			assert(my_fruit:class_name() == "Fruit");
			assert(my_peach:class_name() == "Peach");
		end);

		crystal.test.add("Can check inherits from with objects", function()
			local Fruit = Class:test("Fruit");
			local my_fruit = Fruit:new();
			assert(my_fruit:inherits_from(Fruit));

			local Bird = Class:test("Bird");
			assert(not my_fruit:inherits_from(Bird));
		end);

		crystal.test.add("Can check inherits from with classes", function()
			local Fruit = Class:test("Fruit");
			local Apple = Class:test("Apple", Fruit);
			local Bird = Class:test("Bird");
			assert(Apple:inherits_from(Fruit));
			assert(not Bird:inherits_from(Fruit));
		end);

		crystal.test.add("Can check inherits from with objects of derived classes", function()
			local Fruit = Class:test("Fruit");
			local Peach = Class:test("Peach", Fruit);
			local Apple = Class:test("Apple", Fruit);

			local my_peach = Peach:new();
			assert(my_peach:inherits_from(Fruit));
			assert(my_peach:inherits_from(Peach));
			assert(not my_peach:inherits_from(Apple));

			local my_fruit = Fruit:new();
			assert(my_fruit:inherits_from(Fruit));
			assert(not my_fruit:inherits_from(Peach));
		end);

		crystal.test.add("Can get class by name", function()
			local Fruit = Class("MostUniqueFruit");
			local Peach = Class("VeryUniqueDerivedPeach", Fruit);
			assert(Class:by_name("MostUniqueFruit") == Fruit);
			assert(Class:by_name("VeryUniqueDerivedPeach") == Peach);
			assert(Class:by_name("Berry") == nil);
			assert(Peach:new():inherits_from("VeryUniqueDerivedPeach"));
		end);

		crystal.test.add("Can create object with placement new", function()
			local Fruit = Class:test("Fruit");
			local fruit = {};
			Fruit:placement_new(fruit);
			assert(fruit:class() == Fruit);
		end);

		crystal.test.add("Can alias methods", function()
			local From = Class:test("From");
			local To = Class:test("To");
			To.method = function()
				return true;
			end
			local from = From:new();
			local to = To:new();
			assert(not from.method);
			from:add_alias(to);
			assert(from.method());
		end);

		crystal.test.add("Alias are transitive", function()
			local From = Class:test("From");
			local Middle = Class:test("Middle");
			local To = Class:test("To");
			To.method = function()
				return true;
			end
			local from = From:new();
			local middle = Middle:new();
			local to = To:new();
			from:add_alias(middle);
			middle:add_alias(to);
			assert(from.method());
		end);

		crystal.test.add("Alias work for inherited methods", function()
			local From = Class:test("From");
			local Base = Class:test("Base");
			local To = Class:test("To", Base);
			Base.method = function()
				return true;
			end
			local from = From:new();
			local to = To:new();
			assert(not from.method);
			from:add_alias(to);
			assert(from.method());
		end);

		crystal.test.add("Alias do not apply to variables", function()
			local From = Class:test("From");
			local To = Class:test("To");
			local from = From:new();
			local to = To:new();
			to.member = true;
			from:add_alias(to);
			assert(not from.member);
		end);

		crystal.test.add("Alias calls override self parameter", function()
			local From = Class:test("From");
			local To = Class:test("To");
			To.get_my_class = function(self)
				return self:class();
			end
			local from = From:new();
			local to = To:new();
			from:add_alias(to);
			assert(from:get_my_class() == To);
		end);

		crystal.test.add("Alias error on ambiguous call", function()
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
			from:add_alias(toA);
			from:add_alias(toB);

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
			from:add_alias(toA);
			from:add_alias(toB);

			local success, message = pcall(function()
				from:example();
			end);
			assert(not success);
			assert(#message > 1);
		end);

		--#endregion
	end,
	stop = function()
		Class = nil;
	end,
};
