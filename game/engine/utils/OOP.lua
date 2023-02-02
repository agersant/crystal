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
