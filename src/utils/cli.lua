local CLI = {};

if not gConf.features.cli then
	disableFeature( CLI );
end



local maxUndo = 4;
local isActive = false;
local textInputWasOn;
local lineBuffer = "";
local undoBuffer = { { line = "", cursor = 0 } };
local cursor = 0; 		-- lineBuffer[cursor] is the letter left of the caret
local undoCursor = 1; 	-- undoBuffer[undoCursor] duplicates our lineBuffer and cursor



local insert = function( text )
	local firstNonPrintable = text:find( "[%c]" );
	if firstNonPrintable then
		text = text:sub( 1, firstNonPrintable - 1 );
	end
	local pre = lineBuffer:sub( 1, cursor );
	local post = lineBuffer:sub( cursor + 1 );
	lineBuffer = pre .. text .. post;
	cursor = cursor + #text;
end

local wordLeft = function()
	local out = cursor - 1;
	while out > 0 do
		local spaceLeft = lineBuffer:sub( out, out ):find( "%s" );
		local spaceRight = lineBuffer:sub( out + 1, out + 1 ):find( "%s" );
		if spaceLeft and not spaceRight then
			break;
		end
		out = out - 1;
	end
	return out;
end

local wordRight = function()
	local matchStart, matchEnd = lineBuffer:find( "%s+", cursor + 1 );
	return matchEnd or #lineBuffer;
end

local backspace = function( numDelete )
	assert( numDelete > 0 );
	local pre = lineBuffer:sub( 1, cursor - numDelete );
	local post = lineBuffer:sub( cursor + 1 );
	lineBuffer = pre .. post;
	cursor = cursor - numDelete;
end

local delete = function( numDelete )
	assert( numDelete > 0 );
	local pre = lineBuffer:sub( 1, cursor );
	local post = lineBuffer:sub( cursor + 1 + numDelete );
	lineBuffer = pre .. post;
end

local didInput = function()
	if undoBuffer[undoCursor].line == lineBuffer then
		undoBuffer[undoCursor].cursor = cursor;
	else
		while #undoBuffer > undoCursor do
			table.remove( undoBuffer, #undoBuffer );
		end
		table.insert( undoBuffer, { line = lineBuffer, cursor = cursor } );
		undoCursor = #undoBuffer;
		while #undoBuffer > maxUndo + 1 do
			table.remove( undoBuffer, 1 );
			undoCursor = undoCursor - 1;
		end
	end
end

local undo = function()
	undoCursor = math.max( 1, undoCursor - 1 );
	lineBuffer = undoBuffer[undoCursor].line;
	cursor = undoBuffer[undoCursor].cursor;
end

local redo = function()
	undoCursor = math.min( #undoBuffer, undoCursor + 1 );
	lineBuffer = undoBuffer[undoCursor].line;
	cursor = undoBuffer[undoCursor].cursor;
end



-- PUBLIC API

CLI.toggle = function()
	isActive = not isActive;
	if isActive then
		textInputWasOn = love.keyboard.hasTextInput();
		love.keyboard.setTextInput( true );
	else
		love.keyboard.setTextInput( textInputWasOn );
	end
end

CLI.isActive = function()
	return isActive;
end

CLI.draw = function()
	if not isActive then
		return;
	end
	local pre = lineBuffer:sub( 1, cursor );
	local post = lineBuffer:sub( cursor + 1 );
	local display = pre .. "|" .. post;
	love.graphics.print( "> " .. display, 10, 10 );
end

CLI.textInput = function( self, text )
	insert( text );
	didInput();
end

CLI.keyPressed = function( self, key, scanCode )
	
	local ctrl = love.keyboard.isDown( "lctrl" ) or love.keyboard.isDown( "rctrl" );

	if ctrl and key == "z" then
		undo();
		return;
	elseif ctrl and key == "y" then
		redo();
		didUndoOrRedo = true;
	end
	
	if key == "home" then
		cursor = 0;
	elseif key == "end" then
		cursor = #lineBuffer;
	elseif key == "left" then
		if ctrl then
			cursor = wordLeft();
		else
			cursor = math.max( 0, cursor - 1 );
		end
	elseif key == "right" then
		if ctrl then
			cursor = wordRight();
		else
			cursor = math.min( #lineBuffer, cursor + 1 );
		end
	elseif key == "backspace" then
		if cursor > 0 then
			local numDelete;
			if ctrl then
				numDelete = cursor - wordLeft();
			else
				numDelete = 1;
			end
			backspace( numDelete );
		end
	elseif key == "delete" then
		if cursor < #lineBuffer then
			local numDelete;
			if ctrl then
				numDelete = wordRight() - cursor;
			else
				numDelete = 1;
			end
			delete( numDelete );
		end
	elseif ctrl and key == "v" then
		local clipboard = love.system.getClipboardText();
		insert( clipboard );
	end
	
	didInput();
end



return CLI;
