assert( gUnitTesting );

local love = {};
love.system = {};

local _clipboardText = "";

love.system.getClipboardText = function()
	return _clipboardText;
end

love.system.setClipboardText = function( text )
	_clipboardText = text;
end

return love;