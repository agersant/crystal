require( "src/utils/OOP" );
local Log = require( "src/dev/Log" );
local InputDrivenController = require( "src/scene/controller/InputDrivenController" );
local Actions = require( "src/scene/Actions" );
local Script = require( "src/scene/Script" );
local Entity = require( "src/scene/entity/Entity" );
local Widget = require( "src/ui/Widget" );

local Dialog = Class( "Dialog", Widget );



-- IMPLEMENTATION

local getInputDevice = function( self )
	if self._player then
		local controller = self._player:getController();
		if controller:isInstanceOf( InputDrivenController ) then
			return controller:getInputDevice();
		end
	end
end

local sendCommandSignals = function( self )
	local device = getInputDevice( self );
	if device then
		for _, commandEvent in device:pollEvents() do
			self:signal( commandEvent );
		end
	end
end

local waitForCommandPress = function( self, command )
	local device = getInputDevice( self );
	if device:isCommandActive( command ) then
		self:waitFor( "-" .. command );
	end
	self:waitFor( "+" .. command );
end


-- PUBLIC API

Dialog.init = function( self, scene )
	Dialog.super.init( self, scene, function() end );
	self._owner = nil;
	self._player = nil;
end

Dialog.update = function( self, dt )
	sendCommandSignals( self );
	Dialog.super.update( self, dt );
end

Dialog.setPortait = function( self, portait )
end

Dialog.open = function( self, owner, player )
	assert( owner:isInstanceOf( Script ) );
	assert( player:isInstanceOf( Entity ) );
	assert( self._owner == nil );
	assert( self._player == nil );
	self._owner = owner;
	self._player = player;

	local controller = self._player:getController();
	assert( controller:isIdle() );
	controller:doAction( Actions.idle );
	if controller:isInstanceOf( InputDrivenController ) then
		controller:disable();
	end
end

Dialog.say = function( self, text )

	assert( self._owner ~= nil );
	assert( self._player ~= nil );

	Log:info( "Displaying dialog: " .. text );

	local controller = self._player:getController();
	if controller:isInstanceOf( InputDrivenController ) then
		local dialog = self;
		self:thread( function()
			waitForCommandPress( self, "advanceDialog" );
			dialog._owner:signal( "advanceDialog" );
		end );
	end

	self._owner:waitFor( "advanceDialog" );
end

Dialog.close = function( self )
	assert( self._owner ~= nil );
	assert( self._player ~= nil );

	local controller = self._player:getController();
	if controller:isInstanceOf( InputDrivenController ) then
		controller:enable();
	end

	self._owner = nil;
	self._player = nil;
end



return Dialog;
