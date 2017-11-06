require( "src/utils/OOP" );
local Skill = require( "src/combat/Skill" );
local Actions = require( "src/scene/Actions" );

local Dash = Class( "Dash", Skill );



-- PUBLIC API

Dash.init = function( self, entity )
	Dash.super.init( self, entity );
end

Dash.run = function( self )

	self:thread( function( self)
		while true do
			local entity = self:getEntity();
			local controller = entity:getController();

			self:waitFor( "useSkill" );

			if controller:isIdle() then

				controller:doAction( function( self )
					Actions.idle( self );

					local buildupDuration = 0.24;
					local dashDuration = 0.36;
					local peakSpeed = 300;

					entity:setAnimation( "dash_" .. entity:getDirection4(), true );
					self:wait( buildupDuration );

					local startTime = self._time;
					local endTime = self._time + dashDuration;
					while self._time < endTime do
						local t = ( self._time - startTime ) / ( endTime - startTime );
						entity:setSpeed( peakSpeed * ( 1 - t * t * t ) );
						self:waitFrame();
					end

					Actions.idle( self );
				end );

			end
		end
	end );
end


return Dash;
