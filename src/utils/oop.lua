local OOP = {};

local makeClass = function( name, baseClass )
	local classMeta = {};
	classMeta.__index = baseClass;
	classMeta.__tostring = function( class )
		return "Class definition of '" .. class._name .. "'";
	end
	return setmetatable( {}, classMeta );
end

OOP.class = function( name, baseClass )
	
	local class = makeClass( name, baseClass );
	
	local objMetaTable = {};
	objMetaTable.__index = class;
	objMetaTable.__tostring = function( obj )
		return "Instance of class '" .. obj._class._name .. "'";
	end
	
	class.super = baseClass;
	class._class = class;
	class._name = name;
	class._objMetaTable = objMetaTable;
	
	class.new = function( class, ... )
		local obj = setmetatable( {}, class._objMetaTable );
		obj:init( ... );
		return obj;
	end
	
	return class;
end

return OOP;