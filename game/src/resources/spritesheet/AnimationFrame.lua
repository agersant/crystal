require( "src/utils/OOP" );

local AnimationFrame = Class( "AnimationFrame" );



-- PUBLIC API

AnimationFrame.init = function( self, sheetFrame, animationFrameData )
	assert(animationFrameData.ox);
	assert(animationFrameData.oy);
	self._sheetFrame = sheetFrame;
	self._duration = animationFrameData.duration;
	self._ox = animationFrameData.ox;
	self._oy = animationFrameData.oy;
end

AnimationFrame.getOrigin = function( self )
	return self._ox, self._oy;
end

AnimationFrame.getDuration = function( self )
	return self._duration;
end

AnimationFrame.getSheetFrame = function( self )
	return self._sheetFrame;
end



return AnimationFrame;
