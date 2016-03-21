require( "src/utils/OOP" );
local MathUtils = require( "src/utils/MathUtils" );

local Goal = Class( "Goal" );



Goal.init = function( self, radius )
	self._radius2 = radius * radius;
end

Goal.isPositionAcceptable = function( self, x, y )
	local targetX, targetY = self:getPosition();
	local distToTarget2 = MathUtils.distance2( x, y, targetX, targetY );
	return distToTarget2 <= self._radius2;
end



return Goal;