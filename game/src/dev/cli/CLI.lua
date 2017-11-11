require( "src/utils/OOP" );
local Log = require( "src/dev/Log" );
local AutoComplete = require( "src/dev/cli/AutoComplete" );
local CommandStore = require( "src/dev/cli/CommandStore" );
local Colors = require( "src/resources/Colors" );
local Fonts = require( "src/resources/Fonts" );
local TextInput = require( "src/ui/TextInput" );
local StringUtils = require( "src/utils/StringUtils" );



local CLI = Class( "CLI" );

if not gConf.features.cli then
	disableFeature( CLI );
end



-- IMPLEMENTATION

local maxHistory = 20;
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

local parseInput = function( input )
	local parse = {};
	parse.arguments = {};
	parse.fullText = input;
	parse.commandUntrimmed = parse.fullText:match( "^(%s*[^%s]+)" ) or "";
	parse.command = parse.commandUntrimmed and StringUtils.trim( parse.commandUntrimmed );
	parse.commandIsComplete = parse.fullText:match( "[^%s]+%s" ) ~= nil;
	local args = parse.fullText:sub( #parse.command + 1 );
	for arg in args:gmatch( "%s+[^%s]+" ) do
		table.insert( parse.arguments, StringUtils.trim( arg ) );
	end
	return parse;
end

local getCurrentInput = function( self )
	return self._inputs[self._inputCursor];
end

local getCurrentInputText = function( self )
	return getCurrentInput( self ):getText();
end

local updateAutoComplete = function( self )
	self._autoCompleteCursor = 0;
	self._parsedInput = parseInput( getCurrentInputText( self ) );
	self._autoComplete:feedInput( self._parsedInput );
	self._autoCompleteOutput = self._autoComplete:getSuggestions();
end

local pushCommandToHistory = function( self, command )
	self._inputs[1].submittedCommand = command;
	if #self._inputs > maxHistory then
		table.remove( self._inputs );
	end
	for _, input in ipairs( self._inputs ) do
		input:setText( input.submittedCommand );
		input:rebaseUndoStack();
	end
end

local navigateHistoryBackward = function( self )
	self._inputCursor = math.min( self._inputCursor + 1, #self._inputs );
	updateAutoComplete( self );
end

local navigateHistoryForward = function( self )
	self._inputCursor = math.max( self._inputCursor - 1, 1 );
	updateAutoComplete( self );
end

local submitInput = function( self )
	local command = getCurrentInputText( self );
	if #command == 0 then
		return;
	end
	self:execute( command );
	pushCommandToHistory( self, command );
	table.insert( self._inputs, 1, TextInput:new( maxUndo ) );
	self._inputCursor = 1;
	updateAutoComplete( self );
end



-- PUBLIC API

CLI.init = function( self )
	self._commandStore = CommandStore:new();
	self._autoComplete = AutoComplete:new( self._commandStore );
	self._inputs = { TextInput:new( maxUndo ) };
	self._inputCursor = 1;
	self._isActive = false;
	self._textInputWasOn = false;
	self._keyRepeatWasOn = false;
	self._font = Fonts:get( "dev", fontSize );
	updateAutoComplete( self );
end

CLI.toggle = function( self )
	self._isActive = not self._isActive;
	if self._isActive then
		textInputWasOn = love.keyboard.hasTextInput();
		keyRepeatWasOn = love.keyboard.hasKeyRepeat();
		love.keyboard.setTextInput( true );
		love.keyboard.setKeyRepeat( true );
	else
		love.keyboard.setTextInput( textInputWasOn );
		love.keyboard.setKeyRepeat( keyRepeatWasOn );
	end
end

CLI.isActive = function( self )
	return self._isActive;
end

CLI.draw = function( self )
	if not self:isActive() then
		return;
	end

	local font = self._font;
	love.graphics.setFont( font );

	-- Draw background
	love.graphics.setColor( Colors.darkViridian:alpha( 255 * 0.7 ) );
	love.graphics.rectangle( "fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight() );

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
	love.graphics.print( getCurrentInputText( self ), inputX, inputY );

	-- Draw caret
	local pre = getCurrentInput( self ):getTextLeftOfCursor();
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

CLI.execute = function( self, command )
	local parsedInput = parseInput( command );
	local command = self._commandStore:getCommand( parsedInput.command );
	if not command then
		if #parsedInput.command > 0 then
			Log:error( parsedInput.command .. " is not a valid command" );
		end
		return;
	end
	local useArgs = {};
	for i, arg in ipairs( parsedInput.arguments ) do
		if i > command:getNumArgs() then
			Log:error( "Too many arguments for calling " .. command:getName() );
			return;
		end
		local requiredType = command:getArg( i ).type;
		if not command:typeCheckArgument( i, arg ) then
			Log:error( "Argument #" .. i .. " (" .. command:getArg( i ).name .. ") of command " .. command:getName() .. " must be a " .. requiredType );
			return;
		end
		table.insert( useArgs, command:castArgument( i, arg ) );
	end
	if #useArgs < command:getNumArgs() then
		Log:error( command:getName() .. " requires " .. command:getNumArgs() .. " arguments" );
		return;
	end
	local success, errorMessage = pcall( command:getFunc(), unpack( useArgs ) );
	if not success then
		Log:error( "Error while running command '" .. parsedInput.fullText .. "':\n" .. ( errorMessage or "" ) );
	end
end

CLI.textInput = function( self, text )
	if not self:isActive() then
		return;
	end
	getCurrentInput( self ):textInput( text );
	self._unguidedInput = getCurrentInputText( self );
	updateAutoComplete( self );
end

CLI.keyPressed = function( self, key, scanCode, ctrl )

	if scanCode == "`" then
		self:toggle();
		return;
	end

	if not self:isActive() then
		return;
	end

	if key == "return" or key == "kpenter" then
		submitInput( self );
		return;
	end

	if key == "up" then
		navigateHistoryBackward( self );
	end

	if key == "down" then
		navigateHistoryForward( self );
	end

	if key == "tab" and self._autoCompleteOutput.state == "command" then
		local oldText = getCurrentInputText( self );
		local oldCursor = getCurrentInput( self ):getCursor();
		local numSuggestions = #self._autoCompleteOutput.lines;
		if numSuggestions > 0 then
			if self._autoCompleteCursor == 0 then
				self._autoCompleteCursor = 1;
			else
				self._autoCompleteCursor = ( self._autoCompleteCursor + 1 ) % ( numSuggestions + 1 );
			end
			if self._autoCompleteCursor == 0 then
				getCurrentInput( self ):setText( self._unguidedInput );
			else
				getCurrentInput( self ):setText( self._autoCompleteOutput.lines[self._autoCompleteCursor].command:getName() );
			end
		end
		return;
	end

	local textChanged, cursorMoved = getCurrentInput( self ):keyPressed( key, scanCode, ctrl );
	self._unguidedInput = getCurrentInputText( self );
	if textChanged then
		updateAutoComplete( self );
	end
end

CLI.addCommand = function( self, description, func )
	self._commandStore:addCommand( description, func );
end

CLI.removeCommand = function( self, name )
	self._commandStore:removeCommand( name );
end



local instance = CLI:new();
return instance;
