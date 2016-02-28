require( "src/utils/OOP" );

local SheetFrame = Class( "SheetFrame" );



-- PUBLIC API

SheetFrame.init = function( self, frameData, image )
	assert( type( frameData.x ) == "number" );
	assert( type( frameData.y ) == "number" );
	assert( type( frameData.w ) == "number" );
	assert( type( frameData.h ) == "number" );
	assert( type( frameData.ox ) == "number" );
	assert( type( frameData.oy ) == "number" );
	self._quad = love.graphics.newQuad( frameData.x, frameData.y, frameData.w, frameData.h, image:getDimensions() );
	self._ox = frameData.ox;
	self._oy = frameData.oy;
	self._tags = {};
	if frameData.tags then
		for tagName, tagData in pairs( frameData.tags ) do
			assert( tagData.rect );
			assert( type( tagData.rect.x ) == "number" );
			assert( type( tagData.rect.y ) == "number" );
			assert( type( tagData.rect.w ) == "number" );
			assert( type( tagData.rect.h ) == "number" );
			local w = tagData.rect.w;
			local h = tagData.rect.h;
			local x = tagData.rect.x;
			local y = tagData.rect.y;
			if w < 0 then
				x = x + w;
				w = -w;
			end
			if h < 0 then
				y = y + h;
				h = -h;
			end
			x = x + w / 2;
			y = y + h / 2;
			local shape = love.physics.newRectangleShape( x, y, w, h );
			self._tags[tagName] = shape;
		end
	end
end

SheetFrame.getOrigin = function( self )
	return self._ox, self._oy;
end

SheetFrame.getQuad = function( self )
	return self._quad;
end

SheetFrame.getTagShape = function( self, tagName )
	return self._tags[tagName];
end



return SheetFrame;
