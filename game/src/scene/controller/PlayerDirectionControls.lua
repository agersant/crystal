require( "src/utils/OOP" );
local Script = require( "src/scene/controller/Script" );

local PlayerDirectionControls = Class( "PlayerDirectionControls", Script );



controls = function( self )
	self._enabled = true;
	
	self:thread( function( self )
		while true do
			self:waitForCommandPress( "moveLeft" );
			self._lastXDirInput = -1;
		end
	end );
	
	self:thread( function( self )
		while true do
			self:waitForCommandPress( "moveRight" );
			self._lastXDirInput = 1;
		end
	end );
	
	self:thread( function( self )
		while true do
			self:waitForCommandPress( "moveUp" );
			self._lastYDirInput = -1;
		end
	end );
	
	self:thread( function( self )
		while true do
			self:waitForCommandPress( "moveDown" );
			self._lastYDirInput = 1;
		end
	end );
	
	
	local controller = self:getController();
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
		
		self:waitFrame();
	end
		
end



-- PUBLIC API

PlayerDirectionControls.init = function( self, controller )
	PlayerDirectionControls.super.init( self, controller, controls );
end



return PlayerDirectionControls;
