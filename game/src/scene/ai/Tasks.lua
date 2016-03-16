require( "src/utils/OOP" );
local Actions = require( "src/scene/Actions" );



local Tasks = Class( "Tasks" );

local stepTowards = function( self, targetX, targetY )
	local entity = self:getEntity();
	if self:isIdle() then
		local distToTarget2 = entity:distance2To( targetX, targetY );
		local epsilon = entity:getMovementSpeed() * self._dt / 2;
		if distToTarget2 >= epsilon * epsilon then
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

local followPath = function( self, path )
	for i, waypointX, waypointY in path:vertices() do
		while true do
			local reachedWaypoint = stepTowards( self, waypointX, waypointY );
			if reachedWaypoint then
				break;
			else
				self:waitFrame();
			end
		end
	end
end

Tasks.walkToPoint = function( targetX, targetY, targetRadius )
	return function( self )
		local entity = self:getEntity();
		assert( targetRadius >= 0 );
		local isCloseEnough = function()
			local distToTarget2 = entity:distance2To( targetX, targetY );
			return distToTarget2 <= targetRadius * targetRadius;
		end
		
		if not isCloseEnough() then
		
			-- Follow path
			self:thread( function( self )
				while true do
					self:waitFor( "repath" );
					self:thread( function( self )
						self:endOn( "repath" );
						local path = entity:findPathTo( targetX, targetY );
						followPath( self, path );
						self:waitFrame();
						self:signal( "pathComplete" );
					end );
				end
			end );
		
			-- Trigger repath
			self:thread( function( self )
				while true do
					self:signal( "repath" );
					self:wait( 2 );
				end
			end );
		
			-- Stop when close enough to objective
			self:thread( function( self )
				while true do
					if isCloseEnough() then
						self:signal( "closeEnough" );
					end
					self:wait( .1 );
				end
			end );
			
			self:waitForAny( { "pathComplete", "closeEnough" } );
		end 
		
		if self:isIdle() then
			self:doAction( Actions.idle );
		end
		return isCloseEnough();
	end
end


return Tasks;
