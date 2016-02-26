require( "src/utils/OOP" );

local AnimationFrame = Class( "AnimationFrame" );



-- PUBLIC API

AnimationFrame.init = function( self, sheetFrame, duration )
	self._sheetFrame = sheetFrame;
	self._duration = duration;
end

AnimationFrame.getDuration = function( self )
	return self._duration;
end

AnimationFrame.getSheetFrame = function( self )
	return self._sheetFrame;
end



return AnimationFrame;
