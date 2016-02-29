require( "src/utils/OOP" );
local Input = require( "src/input/Input" );
local Controller = require( "src/scene/controller/Controller" );

local InputDrivenController = Class( "InputDrivenController", Controller );



-- IMPLEMENTATION

local sendCommandSignals = function( self )
	for i, commandEvent in self._inputDevice:pollEvents() do
		self:signal( commandEvent );
	end
end



-- PUBLIC API

InputDrivenController.init = function( self, entity, playerIndex, script )
	InputDrivenController.super.init( self, entity, script );
	self._inputDevice = Input:getDevice( playerIndex );
end

InputDrivenController.getInputDevice = function( self )
	return self._inputDevice;
end

InputDrivenController.update = function( self, dt )
	sendCommandSignals( self );
	InputDrivenController.super.update( self, dt );
end

InputDrivenController.waitForCommandPress = function( self, command )
	while self:getInputDevice():isCommandActive( command ) do
		self:waitFrame();
	end
	self:waitFor( "+" .. command );
end



return InputDrivenController;
