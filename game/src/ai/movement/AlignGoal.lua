require( "src/utils/OOP" );
local Goal = require( "src/ai/movement/Goal" );

local AlignGoal = Class( "AlignGoal", Goal );



AlignGoal.init = function( self, movingEntity, targetEntity, radius )
	assert( type( radius ) == "number" );
	AlignGoal.super.init( self, radius );
	self._movingEntity = movingEntity;
	self._targetEntity = targetEntity;
end

AlignGoal.getPosition = function( self )
	local x, y = self._movingEntity:getPosition();
	local targetX, targetY = self._targetEntity:getPosition();
	local dx, dy = targetX - x, targetY - y;
	if math.abs( dx ) < math.abs( dy ) then
		return targetX, y;
	else
		return x, targetY;
	end
end



return AlignGoal;
