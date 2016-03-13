require( "src/utils/OOP" );
local Log = require( "src/dev/Log" );

local Fonts = Class( "Fonts" );

local pickFont = function( name )
	if name == "dev" then
		return "assets/font/source_code_pro_medium.otf";
	end
	error( "Unknown font: " .. tostring( name ) );
end



-- PUBLIC API

Fonts.init = function( self )
	self:flush();
end

Fonts.getRaw = function( self, name, size )
	if self._fontObjects[name] and self._fontObjects[name][size] then
		return self._fontObjects[name][size];
	end
	self._fontObjects[name] = self._fontObjects[name] or {};
	assert( not self._fontObjects[name][size] );
	
	local fontFile = pickFont( name );
	self._fontObjects[name][size] = love.graphics.newFont( fontFile, size );
	Log:info( "Registered font " .. fontFile .. " at size " .. size );
	return self._fontObjects[name][size];
end

Fonts.flush = function( self )
	self._fontObjects = {};
end



local instance = Fonts:new();
return instance;
