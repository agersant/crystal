require( "src/utils/OOP" );
local Goal = require( "src/ai/movement/Goal" );

local EntityGoal = Class( "EntityGoal", Goal );



EntityGoal.init = function( self, entity, radius )
	EntityGoal.super.init( self, radius );
	self._entity = entity;
end

EntityGoal.getPosition = function( self )
	return self._entity:getPosition();
end



return EntityGoal;