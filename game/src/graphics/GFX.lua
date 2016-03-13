require( "src/utils/OOP" );
local GFXState = require( "src/graphics/GFXState" );

local GFX = Class( "GFX" );
local instance;



local maxStackSize = 10;
local refReset = love.graphics.reset;
local refOrigin = love.graphics.origin;
local refPush = love.graphics.push;
local refPop = love.graphics.pop;
local refScale = love.graphics.scale;
local refPrint = love.graphics.print;



-- IMPLEMENTATION

local getState = function( self )
	return self._stack[#self._stack];
end

local reset = function( self )
	refReset();
	local state = getState( self );
	state:setScaleX( 1 );
	state:setScaleY( 1 );
end

local origin = function( self )
	refOrigin();
	local state = getState( self );
	state:setScaleX( 1 );
	state:setScaleY( 1 );
end

local push = function( self )
	assert( #self._stack <= maxStackSize );
	refPush();
	table.insert( self._stack, getState( self ):clone() );
end

local pop = function( self )
	assert( #self._stack > 0 );
	refPop();
	table.remove( self._stack, #self._stack );
end

local scale = function( self, sx, sy )
	refScale( sx, sy );
	local state = getState( self );
	state:applyScaleX( sx );
	state:applyScaleY( sy );
end



-- PUBLIC API

GFX.init = function( self )
	self._currentState = GFXState:new();
	self._stack = { GFXState:new() };
end

GFX.getMaxScale = function( self )
	local state = getState( self );
	return math.max( state:getScaleX(), state:getScaleY() );
end

love.graphics.reset = function()
	reset( instance );
end

love.graphics.origin = function()
	origin( instance );
end

love.graphics.push = function()
	push( instance );
end

love.graphics.pop = function()
	pop( instance );
end

love.graphics.scale = function( sx, sy )
	scale( instance, sx, sy );
end



instance = GFX:new();
return instance;
