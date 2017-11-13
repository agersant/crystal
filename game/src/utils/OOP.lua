local classIndex = {};
local getClassByName = function( classPackage, name )
	return classIndex[name];
end

local objectConstuctor = function( class, ... )
	local obj = setmetatable( {}, class._objMetaTable );
	if obj.init then
		obj:init( ... );
	end
	return obj;
end

local makeIsInstanceOf = function( class )
	return function( self, otherClass )
		assert( otherClass );
		if class == otherClass then
			return true;
		end
		if self.super then
			return self.super.isInstanceOf( self.super, otherClass );
		end
		return false;
	end
end

local getClassName = function( self )
	return self._class._name;
end

local declareClass = function( self, name, baseClass )

	local classMetaTable = {};
	classMetaTable.__index = baseClass;
	classMetaTable.__tostring = function( class )
		return "Class definition of: " .. class._name;
	end
	local class = setmetatable( {}, classMetaTable );

	local objMetaTable = {};
	objMetaTable.__index = class;
	objMetaTable.__tostring = function( obj )
		return "Instance of class: " .. obj._class._name;
	end

	class._class = class;
	class._name = name;
	class._objMetaTable = objMetaTable;

	class.super = baseClass;
	class.new = objectConstuctor;
	class.getClassName = getClassName;
	class.isInstanceOf = makeIsInstanceOf( class );

	classIndex[name] = class;

	return class;
end



Class = setmetatable( {}, { __call = declareClass } );
Class.getByName = getClassByName;
