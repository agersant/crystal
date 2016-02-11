local Fonts = {};

local fonts = {};

local pickFont = function( name )
	if name == "dev" then
		return "assets/font/SourceCodePro-Medium.otf";
	end
	error( "Unknown font: " .. tostring( name ) );
end

Fonts.get = function( name, size )
	if fonts[name] and fonts[name][size] then
		return fonts[name][size];
	end
	fonts[name] = fonts[name] or {};
	assert( not fonts[name][size] );
	
	local fontFile = pickFont( name );
	fonts[name][size] = love.graphics.newFont( fontFile, size );
	Log.info( "Registered font " .. fontFile .. " at size " .. size );
	return fonts[name][size];
end

return Fonts;