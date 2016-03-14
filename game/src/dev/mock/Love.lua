assert( gUnitTesting );

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

love.graphics.newFont = function()
end;



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
