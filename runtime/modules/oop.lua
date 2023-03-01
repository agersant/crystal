local classes = {};

local get_class_by_name = function(_, name)
	return classes[name];
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
			other_class = classes[other_class];
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

	local allow_redefinition = options and options.allow_redefinition;
	if not allow_redefinition then
		assert(not classes[name]);
	end
	classes[name] = class;

	return class;
end

Class = setmetatable({}, { __call = declare_class });
Class.by_name = get_class_by_name;
Class.test = function(self, name, base_class)
	return declare_class(self, name, base_class, { allow_redefinition = true });
end;

return {
	init = function()
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

		--#endregion
	end
};
