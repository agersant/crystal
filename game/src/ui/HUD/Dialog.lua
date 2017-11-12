require( "src/utils/OOP" );
local Log = require( "src/dev/Log" );
local Colors = require( "src/resources/Colors" );
local Fonts = require( "src/resources/Fonts" );
local InputDrivenController = require( "src/scene/controller/InputDrivenController" );
local Actions = require( "src/scene/Actions" );
local Script = require( "src/scene/Script" );
local Widget = require( "src/ui/Widget" );
local Image = require( "src/ui/core/Image" );

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

Dialog.init = function( self )
	Dialog.super.init( self );
	self._textSpeed = 25;
	self._owner = nil;
	self._player = nil;
	self._targetText = nil;
	self._currentText = nil;
	self._currentGlyphCount = nil;
	self._font = Fonts:get( "body", 16 );

	self:setAlpha( 0 );

	local box = Image:new( scene );
	box:setColor( Colors.black6C );
	box:setAlpha( .8 );
	box:alignBottomCenter( 424, 80 );
	box:offset( 0, -8 );
	self:addChild( box );
end

Dialog.update = function( self, dt )
	sendCommandSignals( self );
	Dialog.super.update( self, dt );

	if self._targetText and self._currentText ~= self._targetText then
		self._currentGlyphCount = self._currentGlyphCount + dt * self._textSpeed;
		self._currentGlyphCount = math.min( self._currentGlyphCount, #self._targetText );
		if math.floor( self._currentGlyphCount ) > 1 then
			-- TODO: This assumes each glyph is one byte, not UTF-8 aware
			self._currentText = string.sub( self._targetText, 1, self._currentGlyphCount );
		else
			self._currentText = "";
		end
	end
end

Dialog.drawSelf = function( self )
	if self._currentText then
		love.graphics.setColor( Colors.white );
		love.graphics.setFont( self._font );
		love.graphics.printf( self._currentText, 108, 190, 336, "left" );
	end
end

Dialog.setPortait = function( self, portait )
end

Dialog.open = function( self, owner, player )
	assert( owner:isInstanceOf( Script ) );
	assert( self._owner == nil );
	assert( self._player == nil );
	self._owner = owner;
	self._player = player;
	self:setAlpha( 1 );

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
	self._targetText = text;
	self._currentText = "";
	self._currentGlyphCount = 0;

	local controller = self._player:getController();
	if controller:isInstanceOf( InputDrivenController ) then
		local dialog = self;
		self:thread( function()
			waitForCommandPress( self, "advanceDialog" );
			if self._currentText ~= self._targetText then
				self._currentText = self._targetText;
				waitForCommandPress( self, "advanceDialog" );
			end
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

	self._targetText = nil;
	self._currentText = nil;
	self._owner = nil;
	self._player = nil;
	self:setAlpha( 0 );
end



return Dialog;
