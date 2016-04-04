assert( gUnitTesting );
local Body = require( "src/dev/mock/love/Body" );
local ChainShape = require( "src/dev/mock/love/ChainShape" );
local Fixture = require( "src/dev/mock/love/Fixture" );
local Image = require( "src/dev/mock/love/Image" );
local Quad = require( "src/dev/mock/love/Quad" );
local SpriteBatch = require( "src/dev/mock/love/SpriteBatch" );
local World = require( "src/dev/mock/love/World" );

local love = {};



--KEYBOARD

love.keyboard = {};
love.keyboard._hasTextInput = false;
love.keyboard._hasKeyRepeat = false;

love.keyboard.hasTextInput = function()
	return love.keyboard._hasTextInput;
end

love.keyboard.hasKeyRepeat = function()
	return love.keyboard._hasKeyRepeat;
end

love.keyboard.setTextInput = function( enabled )
	love.keyboard._hasTextInput = enabled;
end

love.keyboard.setKeyRepeat = function( enabled )
	love.keyboard._hasKeyRepeat = enabled;
end



-- FILESYSTEM

love.filesystem = {};

love.filesystem.setIdentity = function()
end

love.filesystem.isFused = function()
	return false;
end



-- GRAPHICS
love.graphics = {};

love.graphics.getHeight = function()
	return 1080;
end

love.graphics.getWidth = function()
	return 1920;
end

love.graphics.newFont = function()
end

love.graphics.newImage = function()
	return Image:new();
end

love.graphics.newQuad = function()
	return Quad:new();
end

love.graphics.newSpriteBatch = function()
	return SpriteBatch:new();
end



-- PHYSICS

love.physics = {};

love.physics.newBody = function()
	return Body:new();
end

love.physics.newChainShape = function()
	return ChainShape:new();
end

love.physics.newFixture = function()
	return Fixture:new();
end

love.physics.newWorld = function()
	return World:new();
end



-- SYSTEM

love.system = {};
love.system._clipboardText = "";

love.system.getClipboardText = function()
	return love.system._clipboardText;
end

love.system.setClipboardText = function( text )
	love.system._clipboardText = text;
end



return love;
