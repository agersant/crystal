local Fonts = require( "src/resources/fonts" );
local Colors = require( "src/resources/colors" );



local CLI = {};

if not gConf.features.cli then
	disableFeature( CLI );
end



local maxUndo = 20;
local isActive = false;
local textInputWasOn;
local keyRepeatWasOn;
local lineBuffer;
local undoBuffer;
local cursor;
local undoCursor;
local commands = {};

local autoCompleteState;
local autoComplete;
local autoCompleteCursor;
local unguidedInput;

local parsedCommand;
local parsedCommandUntrimmed;
local parsedCommandIsComplete;
local parsedArguments;

local fontSize = 20;
local marginX = 20;
local marginY = 20;
local inputBoxPaddingX = 10;
local inputBoxPaddingY = 4;
local autoCompleteMargin = 16;
local autoCompletePaddingX = 10;
local autoCompletePaddingY = 8;
local autoCompleteCursorWidth = 2;
local autoCompleteArrowMargin = 8;
local autoCompleteArrowWidth = 16;
local autoCompleteArrowHeight = 8;



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

local parseCommand = function()
	parsedCommand = "";
	parsedArguments = {};
	parsedCommandUntrimmed = lineBuffer:match( "^(%s*[^%s]+)" ) or "";
	parsedCommand = parsedCommandUntrimmed and trim( parsedCommandUntrimmed );
	parsedCommandIsComplete = lineBuffer:match( "[^%s]+%s" ) ~= nil;
	
	local args = lineBuffer:sub( #parsedCommand + 1 );
	for arg in args:gmatch( "%s+[^%s]+" ) do 
		table.insert( parsedArguments, trim( arg ) );
	end
end

local typeCheckArgument = function( argument, requiredType )
	if requiredType == "number" then
		return tonumber( argument ) ~= nil;
	end
	if requiredType == "boolean" then
		return argument == "0" or argument == "1" or argument == "true" or argument == "false";
	end
	return true;
end

local castArgument = function( argument, requiredType )
	assert( typeCheckArgument( argument, requiredType ) );
	if requiredType == "number" then
		return tonumber( argument );
	end
	if requiredType == "boolean" then
		return argument == "1" or argument == "true";
	end
	return argument;
end

local updateAutoComplete = function()
	
	parseCommand();
	autoComplete = {};
	
	local input = trim( lineBuffer );
	if #input == 0 then
		autoCompleteState = "command";
		return;
	end
	
	local ref = parsedCommand:lower();
	if not parsedCommandIsComplete then
	
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
		autoComplete.typeChecks = {};
		for i, arg in ipairs( parsedArguments ) do
			local correctType = false;
			if i <= #autoComplete.command.args then
				correctType = typeCheckArgument( parsedArguments[i], autoComplete.command.args[i].type );
			end
			autoComplete.typeChecks[i] = correctType;
		end
	end
	
end

local wipeInput = function()
	lineBuffer = "";
	cursor = 0; -- lineBuffer[cursor] is the letter left of the caret
	
	updateAutoComplete();
	autoCompleteCursor = 0;
	unguidedInput = "";
	
	undoBuffer = { { line = "", cursor = 0 } };
	undoCursor = 1; -- undoBuffer[undoCursor] duplicates our lineBuffer and cursor
end

local runCommand = function()
	parseCommand();
	local ref = parsedCommand:lower();
	local command = commands[ref];
	if not command then
		if #ref > 0 then
			Log.error( parsedCommand .. " is not a valid command" );
		end
		return;
	end
	local useArgs = {};
	for i, arg in ipairs( parsedArguments ) do
		if i > #command.args then
			Log.error( "Too many arguments for calling " .. command.name );
			return;
		end
		local requiredType = command.args[i].type;
		if not typeCheckArgument( arg, requiredType ) then
			Log.error( "Argument #" .. i .. " (" .. command.args[i].name .. ") of command " .. command.name .. " must be a " .. requiredType );
			return;
		end
		table.insert( useArgs, castArgument( arg, requiredType ) );
	end
	if #useArgs < #command.args then
		Log.error( command.name .. " requires " .. #command.args .. " arguments" );
		return;
	end
	command.func( unpack( useArgs ) );
	wipeInput();
end



-- PUBLIC API

CLI.toggle = function()
	isActive = not isActive;
	if isActive then
		textInputWasOn = love.keyboard.hasTextInput();
		keyRepeatWasOn = love.keyboard.hasKeyRepeat();
		love.keyboard.setTextInput( true );
		love.keyboard.setKeyRepeat( true );
		wipeInput();
	else
		love.keyboard.setTextInput( textInputWasOn );
		love.keyboard.setKeyRepeat( keyRepeatWasOn );
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
	
	-- Draw input box
	local inputBoxX = marginX;
	local inputBoxY = marginX;
	local inputBoxWidth = love.graphics.getWidth() - 2 * marginX;
	local inputBoxHeight = font:getHeight() + 2 * inputBoxPaddingY;
	local rounding = 8;
	love.graphics.setColor( Colors.nightSkyBlue );	
	love.graphics.rectangle( "fill", inputBoxX, inputBoxY, inputBoxWidth, inputBoxHeight, rounding, rounding );
	
	-- Draw chevron
	local chevronX = inputBoxX + inputBoxPaddingX;
	local chevronY = inputBoxY + inputBoxPaddingY;
	local chevron = "> ";
	love.graphics.setColor( Colors.white );
	love.graphics.print( chevron, chevronX, chevronY );
	
	-- Draw input text
	local inputX = chevronX + font:getWidth( chevron );
	local inputY = chevronY;
	local pre = lineBuffer:sub( 1, cursor );
	local post = lineBuffer:sub( cursor + 1 );
	love.graphics.setColor( Colors.white );
	love.graphics.print( pre .. post, inputX, inputY );
	
	-- Draw caret
	local caretX = inputX + font:getWidth( pre );
	local caretY = inputY;
	local caretAlpha = .5 * ( 1 + math.sin( love.timer.getTime() * 1000 / 100 ) );
	caretAlpha = caretAlpha * caretAlpha * caretAlpha;
	love.graphics.setColor( Colors.white:alpha( 255 * caretAlpha ) );
	love.graphics.rectangle( "fill", caretX, caretY, 1, font:getHeight() );
	
	-- Compute autocomplete content
	local suggestionX;
	local suggestionsWidth = 0;
	local suggestions = {};
	
	if autoCompleteState == "command" then
		suggestionX = inputX;
		for i, suggestion in ipairs( autoComplete ) do
			local suggestionText = suggestion.command.name;
			suggestionsWidth = font:getWidth( suggestionText );
			table.insert( suggestions, { Colors.white, suggestionText } );
		end
	
	elseif autoCompleteState == "badcommand" then
		suggestionX = inputX;
		local suggestionText = parsedCommand .. " is not a valid command";
		suggestionsWidth = font:getWidth( suggestionText );
		table.insert( suggestions, { Colors.strawberry, suggestionText } );
	
	elseif autoCompleteState == "args" then
		suggestionX = inputX + font:getWidth( parsedCommandUntrimmed .. " " );
		local suggestionText = {};
		for i, arg in ipairs( autoComplete.command.args ) do
			local argString = "";
			if i > 1 then
				argString = " ";
			end
			argString = argString .. arg.name;
			local argColor;
			if autoComplete.typeChecks[i] == true then
				argColor = Colors.ecoGreen;
			elseif autoComplete.typeChecks[i] == false then
				argColor = Colors.strawberry;
			else
				argColor = Colors.rainCloudGrey:alpha( 255 );
			end
			table.insert( suggestionText, argColor );
			table.insert( suggestionText, argString );
			suggestionsWidth = suggestionsWidth + font:getWidth( argString );
		end
		if #suggestionText > 0 then
			table.insert( suggestions, suggestionText );
		end
	else
		error( "Unexpected autocomplete state" );
	end
	
	if #suggestions > 0 then
		-- Draw autocomplete box
		local autoCompleteBoxX = suggestionX - autoCompletePaddingX;
		local autoCompleteBoxY = inputBoxY + inputBoxHeight + autoCompleteMargin;
		local autoCompleteBoxWidth = suggestionsWidth + 2 * autoCompletePaddingX;
		local autoCompleteBoxHeight = #suggestions * font:getHeight() + 2 * autoCompletePaddingY;
		love.graphics.setColor( Colors.nightSkyBlue );	
		love.graphics.rectangle( "fill", autoCompleteBoxX, autoCompleteBoxY, autoCompleteBoxWidth, autoCompleteBoxHeight, 0, 0 );
		
		-- Draw autocomplete arrow
		love.graphics.polygon	( "fill", 	autoCompleteBoxX + autoCompleteArrowMargin, autoCompleteBoxY,
											autoCompleteBoxX + autoCompleteArrowMargin + autoCompleteArrowWidth, autoCompleteBoxY,
											autoCompleteBoxX + autoCompleteArrowMargin + autoCompleteArrowWidth / 2, autoCompleteBoxY - autoCompleteArrowHeight
								);
		
		-- Draw autocomplete content
		love.graphics.setColor( Colors.white );
		local suggestionY = autoCompleteBoxY + autoCompletePaddingY;
		for i, suggestion in ipairs( suggestions ) do
			local suggestionY = suggestionY + ( i - 1 ) * font:getHeight();
			if autoCompleteState == "command" and i == autoCompleteCursor then
				love.graphics.setColor( Colors.oxfordBlue );
				love.graphics.rectangle( "fill", autoCompleteBoxX, suggestionY, autoCompleteBoxWidth, font:getHeight() );
				love.graphics.setColor( Colors.cyan );
				love.graphics.rectangle( "fill", autoCompleteBoxX, suggestionY, autoCompleteCursorWidth, font:getHeight() );
			end
			love.graphics.setColor( Colors.white );
			love.graphics.print( suggestion, suggestionX, suggestionY );
		end
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
	elseif key == "return" or key == "kpenter" then
		runCommand();
		return;
	end
	
	local textChanged = lineBuffer ~= oldLineBuffer;
	local cursorMoved = cursor ~= oldCursor;
	
	if textChanged or cursorMoved then
		pushUndoState();
	end
	
	if key ~= "tab" then
		unguidedInput = lineBuffer;
		if textChanged then
			autoCompleteCursor = 0;
			updateAutoComplete();
		end
	end
end

CLI.addCommand = function( description, func )
	assert( type( description ) == "string" );
	assert( type( func ) == "function" );
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



return CLI;
