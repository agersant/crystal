local classIndex = {};
local getClassByName = function(classPackage, name)
	return classIndex[name];
end

local objectConstructorInPlace = function(class, obj, ...)
	setmetatable(obj, class._objMetaTable);
	if obj.init then
		obj:init(...);
	end
	return obj;
end

local objectConstructor = function(class, ...)
	local obj = {};
	return objectConstructorInPlace(class, obj, ...);
end

local makeIsInstanceOf = function(class)
	return function(self, otherClass)
		assert(otherClass);
		if class == otherClass then
			return true;
		end
		if self.super then
			return self.super.isInstanceOf(self.super, otherClass);
		end
		return false;
	end
end

local getClass = function(self)
	return self._class;
end

local getClassName = function(self)
	return self._class._name;
end

local declareClass = function(self, name, baseClass, options)
	local classMetaTable = {};
	classMetaTable.__index = baseClass;
	classMetaTable.__tostring = function(class)
		return "Class definition of: " .. class._name;
	end
	local class = setmetatable({}, classMetaTable);

	local objMetaTable = {};
	objMetaTable.__index = class;
	objMetaTable.__tostring = function(obj)
		return "Instance of class: " .. obj._class._name;
	end

	class._class = class;
	class._name = name;
	class._objMetaTable = objMetaTable;

	class.super = baseClass;
	class.new = objectConstructor;
	class.placementNew = objectConstructorInPlace;
	class.getClass = getClass;
	class.getClassName = getClassName;
	class.isInstanceOf = makeIsInstanceOf(class);

	local allowRedefinition = _G["hotReloading"];
	allowRedefinition = allowRedefinition or (options and options.allowRedefinition);
	if not allowRedefinition then
		assert(not classIndex[name]);
	end
	classIndex[name] = class;

	return class;
end

Class = setmetatable({}, { __call = declareClass });
Class.getByName = getClassByName;
Class.test = function(self, name, baseClass)
	return declareClass(self, name, baseClass, { allowRedefinition = true });
end;

--#region Tests

crystal.test.add("To string", function()
	local Fruit = Class:test("Fruit");
	local Peach = Class:test("Peach", Fruit);
	local Bird = Class:test("Bird");
	assert(tostring(Fruit));
	assert(#tostring(Fruit) > 0);
	assert(tostring(Fruit) ~= tostring(Bird));
	assert(tostring(Fruit) ~= tostring(Peach));
end);

crystal.test.add("Get class", function()
	local Fruit = Class:test("Fruit");
	local Peach = Class:test("Peach", Fruit);
	local myFruit = Fruit:new();
	local myPeach = Peach:new();
	assert(myFruit:getClass() == Fruit);
	assert(myPeach:getClass() == Peach);
end);

crystal.test.add("Get class name", function()
	local Fruit = Class:test("Fruit");
	local Peach = Class:test("Peach", Fruit);
	local myFruit = Fruit:new();
	local myPeach = Peach:new();
	assert(myFruit:getClassName() == "Fruit");
	assert(myPeach:getClassName() == "Peach");
end);

crystal.test.add("Is instance of", function()
	local Fruit = Class:test("Fruit");
	local myFruit = Fruit:new();
	assert(myFruit:isInstanceOf(Fruit));

	local Bird = Class:test("Bird");
	assert(not myFruit:isInstanceOf(Bird));
end);

crystal.test.add("Is instance of inheritance", function()
	local Fruit = Class:test("Fruit");
	local Peach = Class:test("Peach", Fruit);
	local Apple = Class:test("Apple", Fruit);

	local myPeach = Peach:new();
	assert(myPeach:isInstanceOf(Fruit));
	assert(myPeach:isInstanceOf(Peach));
	assert(not myPeach:isInstanceOf(Apple));

	local myFruit = Fruit:new();
	assert(myFruit:isInstanceOf(Fruit));
	assert(not myFruit:isInstanceOf(Peach));
end);

crystal.test.add("Get by name", function()
	local Fruit = Class("MostUniqueFruit");
	local Peach = Class("VeryUniqueDerivedPeach", Fruit);
	assert(Class:getByName("MostUniqueFruit") == Fruit);
	assert(Class:getByName("VeryUniqueDerivedPeach") == Peach);
	assert(Class:getByName("Berry") == nil);
end);

crystal.test.add("Placement new", function()
	local Fruit = Class:test("Fruit");
	local fruit = {};
	Fruit:placementNew(fruit);
	assert(fruit:getClass() == Fruit);
end);

--#endregion
