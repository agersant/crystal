require( "src/utils/oop" );
local Fonts = require( "src/resources/Fonts" );
local Colors = require( "src/resources/Colors" );
local AutoComplete = require( "src/dev/cli/AutoComplete" );
local UndoStack = require( "src/dev/cli/UndoStack" );

local maxUndo = 20;
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

local CLI = Class( "CLI" );
local instance;

if not gConf.features.cli then
	disableFeature( CLI );
end

local insert = function( self, text )
	local firstNonPrintable = text:find( "[%c]" );
	if firstNonPrintable then
		text = text:sub( 1, firstNonPrintable - 1 );
	end
	local pre = self._lineBuffer:sub( 1, self._cursor );
	local post = self._lineBuffer:sub( self._cursor + 1 );
	self._lineBuffer = pre .. text .. post;
	self._cursor = self._cursor + #text;
end

local findLeftWord = function( self )
	local out = self._cursor - 1;
	while out > 0 do
		local spaceLeft = self._lineBuffer:sub( out, out ):find( "%s" );
		local spaceRight = self._lineBuffer:sub( out + 1, out + 1 ):find( "%s" );
		if spaceLeft and not spaceRight then
			break;
		end
		out = out - 1;
	end
	return out;
end

local findRightWord = function( self )
	local matchStart, matchEnd = self._lineBuffer:find( "%s+", self._cursor + 1 );
	return matchEnd or #self._lineBuffer;
end

local backspace = function( self, numDelete )
	assert( numDelete > 0 );
	local pre = self._lineBuffer:sub( 1, self._cursor - numDelete );
	local post = self._lineBuffer:sub( self._cursor + 1 );
	self._lineBuffer = pre .. post;
	self._cursor = self._cursor - numDelete;
	assert( self._cursor >= 0 );
end

local delete = function( self, numDelete )
	assert( numDelete > 0 );
	local pre = self._lineBuffer:sub( 1, self._cursor );
	local post = self._lineBuffer:sub( self._cursor + 1 + numDelete );
	self._lineBuffer = pre .. post;
end

local pushUndoState = function( self )
	self._undoStack:push( self._lineBuffer, self._cursor );
end

local undo = function( self )
	self._lineBuffer, self._cursor = self._undoStack:undo();
end

local redo = function( self )
	self._lineBuffer, self._cursor = self._undoStack:redo();
end

local parseInput = function( self )
	local parse = {};
	parse.arguments = {};
	parse.fullText = self._lineBuffer;
	parse.commandUntrimmed = self._lineBuffer:match( "^(%s*[^%s]+)" ) or "";
	parse.command = parse.commandUntrimmed and trim( parse.commandUntrimmed );
	parse.commandIsComplete = self._lineBuffer:match( "[^%s]+%s" ) ~= nil;
	local args = self._lineBuffer:sub( #parse.command + 1 );
	for arg in args:gmatch( "%s+[^%s]+" ) do 
		table.insert( parse.arguments, trim( arg ) );
	end
	return parse;
end

local castArgument = function( self, argument, requiredType )
	if requiredType == "number" then
		return tonumber( argument );
	end
	if requiredType == "boolean" then
		return argument == "1" or argument == "true";
	end
	return argument;
end

local updateAutoComplete = function( self )
	self._parsedInput = parseInput( self );
	self._autoComplete:feedInput( self._parsedInput );
	self._autoCompleteOutput = self._autoComplete:getSuggestions();
end

local wipeInput = function( self )
	self._lineBuffer = "";
	self._cursor = 0; -- lineBuffer[cursor] is the letter left of the caret
	self._autoCompleteCursor = 0;
	self._unguidedInput = "";
	updateAutoComplete( self );
	self._undoStack:reset();
end

local runCommand = function( self )
	self._parsedInput = parseInput( self );
	local ref = self._parsedInput.command:lower();
	local command = self._commands[ref];
	if not command then
		if #ref > 0 then
			Log.error( self._parsedInput.command .. " is not a valid command" );
		end
		return;
	end
	local useArgs = {};
	for i, arg in ipairs( self._parsedInput.arguments ) do
		if i > #command.args then
			Log.error( "Too many arguments for calling " .. command.name );
			return;
		end
		local requiredType = command.args[i].type;
		if not self._autoComplete:typeCheckArgument( command, i, arg ) then
			Log.error( "Argument #" .. i .. " (" .. command.args[i].name .. ") of command " .. command.name .. " must be a " .. requiredType );
			return;
		end
		table.insert( useArgs, castArgument( self, arg, requiredType ) );
	end
	if #useArgs < #command.args then
		Log.error( command.name .. " requires " .. #command.args .. " arguments" );
		return;
	end
	command.func( unpack( useArgs ) );
	wipeInput( self );
end



-- PUBLIC API

CLI.init = function( self )
	self._commands = {};
	self._autoComplete = AutoComplete:new( self._commands );
	self._undoStack = UndoStack:new( maxUndo );
	self._isActive = false;
	self._textInputWasOn = false;
	self._keyRepeatWasOn = false;
	wipeInput( self );
end

CLI.toggle = function( self )
	self._isActive = not self._isActive;
	if self._isActive then
		textInputWasOn = love.keyboard.hasTextInput();
		keyRepeatWasOn = love.keyboard.hasKeyRepeat();
		love.keyboard.setTextInput( true );
		love.keyboard.setKeyRepeat( true );
		wipeInput( self );
	else
		love.keyboard.setTextInput( textInputWasOn );
		love.keyboard.setKeyRepeat( keyRepeatWasOn );
	end
end

CLI.isActive = function( self )
	return self._isActive;
end

CLI.draw = function( self )
	if not self._isActive then
		return;
	end
	
	local font = Fonts:get( "dev", fontSize );
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
	love.graphics.print( self._lineBuffer, inputX, inputY );
	
	-- Draw caret
	local pre = self._lineBuffer:sub( 1, self._cursor );
	local caretX = inputX + font:getWidth( pre );
	local caretY = inputY;
	local caretAlpha = .5 * ( 1 + math.sin( love.timer.getTime() * 1000 / 100 ) );
	caretAlpha = caretAlpha * caretAlpha * caretAlpha;
	love.graphics.setColor( Colors.white:alpha( 255 * caretAlpha ) );
	love.graphics.rectangle( "fill", caretX, caretY, 1, font:getHeight() );
	
	-- Compute autocomplete content
	local suggestionX;
	local suggestionsWidth = 0;
	
	for i, suggestion in ipairs( self._autoCompleteOutput.lines ) do
		local suggestionWidth = 0;
		for j = 2, #suggestion.text, 2 do
			suggestionWidth = suggestionWidth + font:getWidth( suggestion.text[j] );
		end
		suggestionsWidth = math.max( suggestionWidth, suggestionsWidth );
	end
	
	if self._autoCompleteOutput.state == "command" then
		suggestionX = inputX;
	elseif self._autoCompleteOutput.state == "badcommand" then
		suggestionX = inputX;
	elseif self._autoCompleteOutput.state == "args" then
		suggestionX = inputX + font:getWidth( self._parsedInput.commandUntrimmed .. " " );
	else
		error( "Unexpected autocomplete state" );
	end
	
	if #self._autoCompleteOutput.lines > 0 then
		-- Draw autocomplete box
		local autoCompleteBoxX = suggestionX - autoCompletePaddingX;
		local autoCompleteBoxY = inputBoxY + inputBoxHeight + autoCompleteMargin;
		local autoCompleteBoxWidth = suggestionsWidth + 2 * autoCompletePaddingX;
		local autoCompleteBoxHeight = #self._autoCompleteOutput.lines * font:getHeight() + 2 * autoCompletePaddingY;
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
		for i, suggestion in ipairs( self._autoCompleteOutput.lines ) do
			local suggestionY = suggestionY + ( i - 1 ) * font:getHeight();
			if self._autoCompleteOutput.state == "command" and i == self._autoCompleteCursor then
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
	insert( self, text );
	pushUndoState( self );
	updateAutoComplete( self );
end

CLI.keyPressed = function( self, key, scanCode )
	
	local ctrl = love.keyboard.isDown( "lctrl" ) or love.keyboard.isDown( "rctrl" );

	if ctrl and key == "z" then
		undo( self );
		updateAutoComplete( self );
		return;
	elseif ctrl and key == "y" then
		redo( self );
		updateAutoComplete( self );
		return;
	end
	
	local oldLineBuffer = self._lineBuffer;
	local oldCursor = self._cursor;
	
	if key == "home" then
		self._cursor = 0;
	elseif key == "end" then
		self._cursor = #self._lineBuffer;
	elseif key == "left" then
		if ctrl then
			self._cursor = findLeftWord( self );
		else
			self._cursor = math.max( 0, self._cursor - 1 );
		end
	elseif key == "right" then
		if ctrl then
			self._cursor = findRightWord( self );
		else
			self._cursor = math.min( #self._lineBuffer, self._cursor + 1 );
		end
	elseif key == "backspace" then
		if self._cursor > 0 then
			local numDelete;
			if ctrl then
				numDelete = self._cursor - findLeftWord( self );
			else
				numDelete = 1;
			end
			backspace( self, numDelete );
		end
	elseif key == "delete" then
		if self._cursor < #self._lineBuffer then
			local numDelete;
			if ctrl then
				numDelete = findRightWord( self ) - self._cursor;
			else
				numDelete = 1;
			end
			delete( self, numDelete );
		end
	elseif ctrl and key == "v" then
		local clipboard = love.system.getClipboardText();
		insert( self, clipboard );
	elseif key == "tab" and self._autoCompleteOutput.state == "command" then
		local numSuggestions = #self._autoCompleteOutput.lines;
		if numSuggestions > 0 then
			if self._autoCompleteCursor == 0 then
				self._autoCompleteCursor = 1;
			else
				self._autoCompleteCursor = ( self._autoCompleteCursor + 1 ) % ( numSuggestions + 1 );
			end
			if self._autoCompleteCursor == 0 then
				self._lineBuffer = unguidedInput;
			else
				self._lineBuffer = self._autoCompleteOutput.lines[self._autoCompleteCursor].command.name;
			end
			self._cursor = #self._lineBuffer;
		end
	elseif key == "return" or key == "kpenter" then
		runCommand( self );
		return;
	end
	
	local textChanged = self._lineBuffer ~= oldLineBuffer;
	local cursorMoved = self._cursor ~= oldCursor;
	
	if textChanged or cursorMoved then
		pushUndoState( self );
	end
	
	if key ~= "tab" then
		unguidedInput = self._lineBuffer;
		if textChanged then
			self._autoCompleteCursor = 0;
			updateAutoComplete( self );
		end
	end
end

CLI.addCommand = function( self, description, func )
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
	assert( not self._commands[ref] );
	self._commands[ref] = command;
end



instance = CLI:new();
return instance;
