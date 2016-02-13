assert( gUnitTesting );

local love = {};


-- FILESYSTEM

love.filesystem = {};

love.filesystem.isFused = function()
	return false;
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
