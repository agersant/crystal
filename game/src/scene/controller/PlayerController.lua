require( "src/utils/OOP" );
local Input = require( "src/input/Input" );
local Actions = require( "src/scene/Actions" );
local InputDrivenController = require( "src/scene/controller/InputDrivenController" );
local Script = require( "src/scene/controller/Script" );

local PlayerController = Class( "PlayerController", InputDrivenController );



-- CONTROLS

local addDirectionControls = function( self )
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
	
	self:thread( function( self )
		local entity = self:getEntity();
			local controller = self:getController();
			while true do
				if controller:isIdle() then
					local inputDevice = controller:getInputDevice();
					local left = inputDevice:isCommandActive( "moveLeft" );
					local right = inputDevice:isCommandActive( "moveRight" );
					local up = inputDevice:isCommandActive( "moveUp" );
					local down = inputDevice:isCommandActive( "moveDown" );
					if left or right or up or down then
						local xDir, yDir;
						if left and right then
							xDir = self._lastXDirInput;
						else
							xDir = left and -1 or right and 1 or 0;
						end
						if up and down then
							yDir = self._lastYDirInput;
						else
							yDir = up and -1 or down and 1 or 0;
						end
						entity:setDirection8( xDir, yDir );
					end
				end
				self:waitFrame();
			end
	end );
end

local walkControls = function( self )
	local entity = self:getEntity();
	local controller = self:getController();
	while true do
		if controller:isIdle() then
			local left = controller:getInputDevice():isCommandActive( "moveLeft" );
			local right = controller:getInputDevice():isCommandActive( "moveRight" );
			local up = controller:getInputDevice():isCommandActive( "moveUp" );
			local down = controller:getInputDevice():isCommandActive( "moveDown" );
			if left or right or up or down then
				controller:doAction( Actions.walk( entity:getAngle() ) );
			else
				controller:doAction( Actions.idle );
			end
		end
		self:waitFrame();
	end
end

local attackControls = function( self )
	while true do
		self:waitForCommandPress( "attack" );
		if self:isIdle() then
			self:doAction( Actions.attack );
		end
		self:waitFrame();
	end
end

local skillControls = function( skillIndex )
	return function( self )
		local entity = self:getEntity();
		local useSkillCommand = "useSkill" .. skillIndex;
		while true do
			self:waitForCommandPress( useSkillCommand );
			local skill = entity:getSkill( skillIndex );
			if skill then
				skill:use();
			end
		end
	end
end	

local playerControllerScript = function( self )
	addDirectionControls( self );
	self:thread( walkControls );
	self:thread( attackControls );
	for i = 1, 4 do
		self:thread( skillControls( i ) );
	end
end


-- PUBLIC API

PlayerController.init = function( self, entity, playerIndex )
	PlayerController.super.init( self, entity, playerControllerScript, playerIndex );
end



return PlayerController;
