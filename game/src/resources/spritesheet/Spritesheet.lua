require( "src/utils/OOP" );
local Animation = require( "src/resources/spritesheet/Animation" );
local SheetFrame = require( "src/resources/spritesheet/SheetFrame" );

local Spritesheet = Class( "Spritesheet" );



-- PUBLIC API

Spritesheet.init = function( self, sheetData, image )
	self._image = image;
	self._frames = {};
	self._animations = {};
	self._defaultAnimationName = nil;
	for k, frameData in pairs( sheetData.content.frames ) do
		assert( not self._frames[k] );
		self._frames[k] = SheetFrame:new( frameData, image );
	end
	for k, animationData in pairs( sheetData.content.animations ) do
		assert( not self._animations[k] );
		self._animations[k] = Animation:new( self, animationData );
		if not self._defaultAnimationName then
			self._defaultAnimationName = k;
		end
	end
end

Spritesheet.getImage = function( self )
	return self._image;
end

Spritesheet.getFrame = function( self, frameName )
	return self._frames[frameName];
end

Spritesheet.getAnimation = function( self, animationName )
	return self._animations[animationName];
end

Spritesheet.getDefaultAnimationName = function( self )
	return self._defaultAnimationName;
end



return Spritesheet;
