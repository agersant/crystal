require( "src/utils/OOP" );
local Log = require( "src/dev/Log" );
local InputDrivenController = require( "src/scene/controller/InputDrivenController" );
local Entity = require( "src/scene/entity/Entity" );
local Script = require( "src/scene/Script" );
local Widget = require( "src/ui/Widget" );

local Dialog = Class( "Dialog", Widget );



Dialog.init = function( self, scene )
	Dialog.super.init( self, scene, function() end );
	self._owner = nil;
	self._player = nil;
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
end

Dialog.say = function( self, text )

	assert( self._owner ~= nil );
	assert( self._player ~= nil );

	Log:info( "Displaying dialog: " .. text );

	local controller = self._player:getController();
	if controller:isInstanceOf( InputDrivenController ) then
		local dialog = self;
		local inputDevice = controller:getInputDevice();
		controller:thread( function()
			controller:waitForCommandPress( "advanceDialog" );
			dialog._owner:signal( "advanceDialog" );
		end );
	end

	self._owner:waitFor( "advanceDialog" );
end

Dialog.close = function( self )
	assert( self._owner ~= nil );
	assert( self._player ~= nil );
	self._owner = nil;
	self._player = nil;
end



return Dialog;
