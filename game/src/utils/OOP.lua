local makeClass = function( name, baseClass )
	local classMeta = {};
	classMeta.__index = baseClass;
	classMeta.__tostring = function( class )
		return "Class definition of: " .. class._name;
	end
	return setmetatable( {}, classMeta );
end


Class = function( name, baseClass )
	
	local class = makeClass( name, baseClass );
	
	local objMetaTable = {};
	objMetaTable.__index = class;
	objMetaTable.__tostring = function( obj )
		return "Instance of class: " .. obj._class._name;
	end
	
	class.super = baseClass;
	class._class = class;
	class._name = name;
	class._objMetaTable = objMetaTable;
	
	class.new = function( class, ... )
		local obj = setmetatable( {}, class._objMetaTable );
		if obj.init then
			obj:init( ... );
		end
		return obj;
	end
	
	class.isInstanceOf = function( self, otherClass )
		if class == otherClass then
			return true;
		end
		if self.super then
			return self.super.isInstanceOf( self, otherClass );
		end
		return false;
	end
	
	return class;
end
