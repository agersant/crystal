local Fonts = require( "src/resources/Fonts" );
local Colors = require( "src/resources/Colors" );
local AutoComplete = require( "src/dev/cli/AutoComplete" );
local UndoStack = require( "src/dev/cli/UndoStack" );


local CLI = {};

if not gConf.features.cli then
	disableFeature( CLI );
end


CLI._commands = {};
CLI._autoComplete = AutoComplete:new( CLI._commands );
CLI._undoStack = UndoStack:new( 20 );
CLI._parsedInput = {};

local isActive = false;
local textInputWasOn;
local keyRepeatWasOn;
local lineBuffer;
local cursor;

local autoCompleteCursor;
local unguidedInput;

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
	CLI._undoStack:push( lineBuffer, cursor );
end

local undo = function()
	lineBuffer, cursor = CLI._undoStack:undo();
end

local redo = function()
	lineBuffer, cursor = CLI._undoStack:redo();
end

local parseInput = function()
	local parse = {};
	parse.arguments = {};
	parse.fullText = lineBuffer;
	parse.commandUntrimmed = lineBuffer:match( "^(%s*[^%s]+)" ) or "";
	parse.command = parse.commandUntrimmed and trim( parse.commandUntrimmed );
	parse.commandIsComplete = lineBuffer:match( "[^%s]+%s" ) ~= nil;
	local args = lineBuffer:sub( #parse.command + 1 );
	for arg in args:gmatch( "%s+[^%s]+" ) do 
		table.insert( parse.arguments, trim( arg ) );
	end
	return parse;
end

local castArgument = function( argument, requiredType )
	if requiredType == "number" then
		return tonumber( argument );
	end
	if requiredType == "boolean" then
		return argument == "1" or argument == "true";
	end
	return argument;
end

local updateAutoComplete = function()
	CLI._parsedInput = parseInput();
	CLI._autoComplete:feedInput( CLI._parsedInput );
	CLI._autoCompleteOutput = CLI._autoComplete:getSuggestions();
end

local wipeInput = function()
	lineBuffer = "";
	cursor = 0; -- lineBuffer[cursor] is the letter left of the caret
	
	updateAutoComplete();
	autoCompleteCursor = 0;
	unguidedInput = "";
	
	CLI._undoStack:reset();
end

local runCommand = function()
	parseInput();
	local ref = CLI._parsedInput.command:lower();
	local command = CLI._commands[ref];
	if not command then
		if #ref > 0 then
			Log.error( CLI._parsedInput.command .. " is not a valid command" );
		end
		return;
	end
	local useArgs = {};
	for i, arg in ipairs( CLI._parsedInput.arguments ) do
		if i > #command.args then
			Log.error( "Too many arguments for calling " .. command.name );
			return;
		end
		local requiredType = command.args[i].type;
		if not CLI._autoComplete:typeCheckArgument( command, i, arg ) then
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
	love.graphics.setColor( Colors.white );
	love.graphics.print( lineBuffer, inputX, inputY );
	
	-- Draw caret
	local pre = lineBuffer:sub( 1, cursor );
	local caretX = inputX + font:getWidth( pre );
	local caretY = inputY;
	local caretAlpha = .5 * ( 1 + math.sin( love.timer.getTime() * 1000 / 100 ) );
	caretAlpha = caretAlpha * caretAlpha * caretAlpha;
	love.graphics.setColor( Colors.white:alpha( 255 * caretAlpha ) );
	love.graphics.rectangle( "fill", caretX, caretY, 1, font:getHeight() );
	
	-- Compute autocomplete content
	local suggestionX;
	local suggestionsWidth = 0;
	
	for i, suggestion in ipairs( CLI._autoCompleteOutput.lines ) do
		local suggestionWidth = 0;
		for j = 2, #suggestion.text, 2 do
			suggestionWidth = suggestionWidth + font:getWidth( suggestion.text[j] );
		end
		suggestionsWidth = math.max( suggestionWidth, suggestionsWidth );
	end
	
	if CLI._autoCompleteOutput.state == "command" then
		suggestionX = inputX;
	elseif CLI._autoCompleteOutput.state == "badcommand" then
		suggestionX = inputX;
	elseif CLI._autoCompleteOutput.state == "args" then
		suggestionX = inputX + font:getWidth( CLI._parsedInput.commandUntrimmed .. " " );
	else
		error( "Unexpected autocomplete state" );
	end
	
	if #CLI._autoCompleteOutput.lines > 0 then
		-- Draw autocomplete box
		local autoCompleteBoxX = suggestionX - autoCompletePaddingX;
		local autoCompleteBoxY = inputBoxY + inputBoxHeight + autoCompleteMargin;
		local autoCompleteBoxWidth = suggestionsWidth + 2 * autoCompletePaddingX;
		local autoCompleteBoxHeight = #CLI._autoCompleteOutput.lines * font:getHeight() + 2 * autoCompletePaddingY;
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
		for i, suggestion in ipairs( CLI._autoCompleteOutput.lines ) do
			local suggestionY = suggestionY + ( i - 1 ) * font:getHeight();
			if autoCompleteState == "command" and i == autoCompleteCursor then
				love.graphics.setColor( Colors.oxfordBlue );
				love.graphics.rectangle( "fill", autoCompleteBoxX, suggestionY, autoCompleteBoxWidth, font:getHeight() );
				love.graphics.setColor( Colors.cyan );
				love.graphics.rectangle( "fill", autoCompleteBoxX, suggestionY, autoCompleteCursorWidth, font:getHeight() );
			end
			love.graphics.setColor( Colors.white );
			love.graphics.print( suggestion.text, suggestionX, suggestionY );
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
	elseif key == "tab" and CLI._autoCompleteOutput.state == "command" then
		local numSuggestions = #CLI._autoCompleteOutput.lines;
		if numSuggestions > 0 then
			if autoCompleteCursor == 0 then
				autoCompleteCursor = 1;
			else
				autoCompleteCursor = ( autoCompleteCursor + 1 ) % ( numSuggestions + 1 );
			end
			if autoCompleteCursor == 0 then
				lineBuffer = unguidedInput;
			else
				lineBuffer = CLI._autoCompleteOutput.lines[autoCompleteCursor].command.name;
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
	assert( not CLI._commands[ref] );
	CLI._commands[ref] = command;
end



return CLI;
