require( "src/utils/OOP" );
local Actions = require( "src/scene/Actions" );
local MathUtils = require( "src/utils/MathUtils" );



local Tasks = Class( "Tasks" );

Tasks.stepTowards = function( self, targetX, targetY )
	local entity = self:getEntity();
	if self:isIdle() then
		local distToTarget2 = entity:distance2To( targetX, targetY );
		local epsilon = entity:getMovementSpeed() * self._dt / 2;
		if distToTarget2 >= epsilon * epsilon then -- TODO magic value!
			local x, y = entity:getPosition();
			local deltaX, deltaY = targetX - x, targetY - y;
			local angle = math.atan2( deltaY, deltaX );
			entity:setAngle( angle );
			self:doAction( Actions.walk );
			return false;
		else
			entity:setPosition( targetX, targetY );
			return true;
		end
	end
end

Tasks.walkToPoint = function( self, targetX, targetY, targetRadius )
	
	local entity = self:getEntity();
	assert( targetRadius >= 0 );
	local targetRadius2 = targetRadius * targetRadius;
	
	local path = entity:findPathTo( targetX, targetY );
	
	for _, waypointX, waypointY in path:vertices() do
		while true do
			if self:isIdle() then
				local distToTarget2 = entity:distance2To( targetX, targetY );
				if distToTarget2 <= targetRadius2 then
					break;
				end
				local reachedWaypoint = Tasks.stepTowards( self, waypointX, waypointY );
				if reachedWaypoint then
					break;
				else
					self:waitFrame();
				end
			end
		end
	end
	
	self:doAction( Actions.idle );
	return true;
end



return Tasks;
