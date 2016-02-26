require( "src/utils/OOP" );
local AnimationFrame = require( "src/resources/spritesheet/AnimationFrame" );

local Animation = Class( "Animation" );



-- PUBLIC API

Animation.init = function( self, sheet, animationData )
	self._loop = animationData.loop;
	self._animationFrames = {};
	self._duration = 0;
	for k, frameData in pairs( animationData.frames ) do
		frameData.duration = frameData.duration or 1;
		local sheetFrame = sheet:getFrame( frameData.id );
		local animationFrame = AnimationFrame:new( sheetFrame, frameData.duration );
		table.insert( self._animationFrames, animationFrame );
		self._duration = self._duration + frameData.duration;
	end
	assert( #self._animationFrames > 0 );
end

Animation.getDuration = function( self )
	return self._duration;
end

Animation.getFrameAtTime = function( self, t )
	local outFrame;
	if #self._animationFrames == 1 then
		outFrame = self._animationFrames[1];
	else
		if self._loop then
			t = t % self._duration;
		else
			t = math.min( t, self._duration );
		end
		assert( t <= self._duration );
		
		local curTime = 0;
		for i, frame in ipairs( self._animationFrames ) do
			curTime = curTime + frame:getDuration()
			if t <= curTime then
				outFrame = frame;
				break;
			end
		end
	end
	return outFrame:getSheetFrame();
end



return Animation;
