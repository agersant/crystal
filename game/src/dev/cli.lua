local Fonts = require( "src/resources/fonts" );



local CLI = {};

if not gConf.features.cli then
	disableFeature( CLI );
end



local maxUndo = 20;
local isActive = false;
local textInputWasOn;
local lineBuffer = "";
local undoBuffer = { { line = "", cursor = 0 } };
local cursor = 0; 		-- lineBuffer[cursor] is the letter left of the caret
local undoCursor = 1; 	-- undoBuffer[undoCursor] duplicates our lineBuffer and cursor
local commands = {};

local autoCompleteState = "command";
local autoComplete = {};
local autoCompleteCursor = 0;
local unguidedInput = "";

local inputCommand = "";

local fontSize = 20;
local marginX = 20;
local marginY = 20;


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

local pushUndoState = function()
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

local updateAutoComplete = function()
	autoComplete = {};
	
	local input = trim( lineBuffer );
	if #input == 0 then
		autoCompleteState = "command";
		return;
	end
	
	inputCommand = lineBuffer:match( "([^%s]+)%s+" );
	local ref = inputCommand and inputCommand:lower();
	
	if not inputCommand then
	
		autoCompleteState = "command";
		local hasStrongMatch = false;
		for name, command in pairs( commands ) do
			local matchStart, matchEnd = name:lower():find( input:lower() );
			if matchStart then
				hasStrongMatch = matchStart == 1;
				local suggestion = { command = command, matchStart = matchStart, matchEnd = matchEnd };
				table.insert( autoComplete, suggestion );
			end
		end
		if hasStrongMatch then
			for i = #autoComplete, 1, -1 do
				if autoComplete[i].matchStart ~= 1 then
					table.remove( autoComplete, i );
				end
			end
		end
		
	elseif not commands[ref] then
		autoCompleteState = "badcommand";
	
	else
		autoCompleteState = "args";
		autoComplete.command = commands[ref];
	end
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
	
	local font = Fonts.get( "dev", fontSize );
	love.graphics.setFont( font );
	
	-- Draw chevron
	local chevronX = marginX;
	local chevronY = marginY;
	local chevron = "> ";
	love.graphics.print( chevron, chevronX, chevronY );
	
	-- Draw input text
	local inputX = chevronX + font:getWidth( chevron );
	local inputY = chevronY;
	local pre = lineBuffer:sub( 1, cursor );
	local post = lineBuffer:sub( cursor + 1 );
	love.graphics.print( pre .. post, inputX, inputY );
	
	-- Draw caret
	local caretX = inputX + font:getWidth( pre );
	local caretY = inputY;
	local caretAlpha = .5 * ( 1 + math.sin( love.timer.getTime() * 1000 / 100 ) );
	caretAlpha = caretAlpha * caretAlpha * caretAlpha;
	love.graphics.setColor( 255, 255, 255, 255 * caretAlpha );
	love.graphics.rectangle( "fill", caretX, caretY, 1, font:getHeight() );
	love.graphics.setColor( 255, 255, 255, 255 );
	
	-- Draw autocomplete
	if autoCompleteState == "command" then
		for i, suggestion in ipairs( autoComplete ) do
			local suggestionText = suggestion.command.name;
			local suggestionX = inputX;
			local suggestionY = inputY + i * font:getHeight();
			love.graphics.print( suggestionText, suggestionX, suggestionY );
		end
	elseif autoCompleteState == "badcommand" then
		local suggestionX = inputX;
		local suggestionY = inputY + font:getHeight();
		love.graphics.print( inputCommand .. " is not a valid command", suggestionX, suggestionY );
	elseif autoCompleteState == "args" then
		local suggestionText = "";
		local suggestionX = inputX + font:getWidth( inputCommand .. " " );
		local suggestionY = inputY + font:getHeight();
		for i, arg in ipairs( autoComplete.command.args ) do
			if i > 1 then
				suggestionText = suggestionText .. " ";
			end
			suggestionText = suggestionText .. arg.name;
		end
		love.graphics.print( suggestionText, suggestionX, suggestionY );
	end
end

CLI.textInput = function( self, text )
	insert( text );
	pushUndoState();
	updateAutoComplete();
end

CLI.keyPressed = function( self, key, scanCode )
	
	local ctrl = love.keyboard.isDown( "lctrl" ) or love.keyboard.isDown( "rctrl" );

	if ctrl and key == "z" then
		undo();
		updateAutoComplete();
		return;
	elseif ctrl and key == "y" then
		redo();
		updateAutoComplete();
		return;
	end
	
	local oldLineBuffer = lineBuffer;
	local oldCursor = cursor;
	
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
	elseif key == "tab" then
		if #autoComplete > 0 then
			if autoCompleteCursor == 0 then
				autoCompleteCursor = 1;
			else
				autoCompleteCursor = ( autoCompleteCursor + 1 ) % ( #autoComplete + 1 );
			end
			if autoCompleteCursor == 0 then
				lineBuffer = unguidedInput;
			else
				lineBuffer = autoComplete[autoCompleteCursor].command.name;
			end
			cursor = #lineBuffer;
		end
	end
	
	local textChanged = lineBuffer ~= oldLineBuffer;
	local cursorMoved = cursor ~= oldCursor;
	
	if textChanged or cursorMoved then
		pushUndoState();
	end
	
	if key ~= "tab" then
		unguidedInput = lineBuffer;
		if textChanged then
			updateAutoComplete();
		end
	end
end

CLI.addCommand = function( description, func )
	description = trim( description );
	
	local command = {};
	command.name = description:match( "[^%s]+" );
	command.args = {};
	command.func = func;
	
	local args = trim( description:sub( #command.name + 1 ) );
	for argDescription in string.gmatch( args, "%a+[%d%a]-:%a+") do
		local arg = {};
		arg.name, arg.type = argDescription:match( "(.*):(.*)" );
		table.insert( command.args, arg );
	end
	
	local ref = command.name:lower();
	assert( not commands[ref] );
	commands[ref] = command;
end

CLI.addCommand( "loadImage name:string" );
CLI.addCommand( "loadMap mapName:string startX:number startY:number" );
CLI.addCommand( "reloadMap" );
CLI.addCommand( "playMusic" );
CLI.addCommand( "stopMusic" );

return CLI;
