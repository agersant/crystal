require( "src/utils/OOP" );
local Input = require( "src/input/Input" );
local Controller = require( "src/scene/component/Controller" );

local InputDrivenController = Class( "InputDrivenController", Controller );



-- IMPLEMENTATION

local sendCommandSignals = function( self )
	for _, commandEvent in self._inputDevice:pollEvents() do
		self:signal( commandEvent );
	end
end



-- PUBLIC API

InputDrivenController.init = function( self, entity, scriptContent, playerIndex )
	InputDrivenController.super.init( self, entity, scriptContent );
	self._playerIndex = playerIndex;
	self._inputDevice = Input:getDevice( playerIndex );
end

InputDrivenController.getAssignedPlayer = function( self )
	return self._playerIndex;
end

InputDrivenController.getInputDevice = function( self )
	return self._inputDevice;
end

InputDrivenController.update = function( self, dt )
	sendCommandSignals( self );
	InputDrivenController.super.update( self, dt );
end

InputDrivenController.waitForCommandPress = function( self, command )
	if self._inputDevice:isCommandActive( command ) then
		self:waitFor( "-" .. command );
	end
	self:waitFor( "+" .. command );
end



return InputDrivenController;
