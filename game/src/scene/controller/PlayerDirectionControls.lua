require( "src/utils/OOP" );

local PlayerDirectionControls = Class( "PlayerDirectionControls" );



-- PUBLIC API

PlayerDirectionControls.init = function( self, controller )
	
	assert( controller );
	self._enabled = true;
	
	controller:thread( function( controller )
		while true do
			controller:waitForCommandPress( "moveLeft" );
			self._lastXDirInput = -1;
		end
	end );
	
	controller:thread( function( controller )
		while true do
			controller:waitForCommandPress( "moveRight" );
			self._lastXDirInput = 1;
		end
	end );
	
	controller:thread( function( controller )
		while true do
			controller:waitForCommandPress( "moveUp" );
			self._lastYDirInput = -1;
		end
	end );
	
	controller:thread( function( controller )
		while true do
			controller:waitForCommandPress( "moveDown" );
			self._lastYDirInput = 1;
		end
	end );
	
	controller:thread( function( controller )
	
		while true do
		
			if self._enabled and controller:isIdle() then
				local inputDevice = controller:getInputDevice();
				local left = inputDevice:isCommandActive( "moveLeft" );
				local right = inputDevice:isCommandActive( "moveRight" );
				local up = inputDevice:isCommandActive( "moveUp" );
				local down = inputDevice:isCommandActive( "moveDown" );
				
				if left or right or up or down then
					local xDir, yDir;
					
					if left and right then
						xDir = self._lastXDirInput;
					elseif left then
						xDir = -1;
					elseif right then
						xDir = 1;
					else
						xDir = 0;
					end
					
					if up and down then
						yDir = self._lastYDirInput;
					elseif up then
						yDir = -1;
					elseif down then
						yDir = 1;
					else
						yDir = 0;
					end
					
					controller:getEntity():setDirection8( xDir, yDir );
				end
			end
			
			controller:waitFrame();
		end
		
	end );
	
end



return PlayerDirectionControls;
