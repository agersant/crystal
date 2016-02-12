require( "src/utils/oop" );
local Colors = require( "src/resources/Colors" );

local AutoComplete = Class( "AutoComplete" );



-- IMPLEMENTATION

local getSuggestionsForCommand = function( self, input )
	
	-- Find commands to suggest
	local matches = {};
	local hasStrongMatch = false;
	for name, command in pairs( self._commands ) do
		local matchStart, matchEnd = name:lower():find( input.fullText:lower() );
		if matchStart then
			hasStrongMatch = hasStrongMatch or matchStart == 1;
			local match = { command = command, matchStart = matchStart, matchEnd = matchEnd };
			table.insert( matches, match );
		end
	end
	
	-- Only keep strong matches
	if hasStrongMatch then
		for i = #matches, 1, -1 do
			if matches[i].matchStart ~= 1 then
				table.remove( matches, i );
			end
		end
	end
	
	table.sort( matches, function( a, b ) return a.command.name < b.command.name; end );
	
	-- Colorize!
	local lines = {};
	for i, match in ipairs( matches ) do
		local textChunks = {};
		local preMatch = match.matchStart > 1 and match.command.name:sub( 1, match.matchStart - 1 ) or "";
		local matchText = match.command.name:sub( match.matchStart, match.matchEnd );
		local postMatch = match.command.name:sub( match.matchEnd + 1 );
		if #preMatch > 0 then -- TODO File Love2D bug report for this workaround
			table.insert( textChunks, Colors.rainCloudGrey );
			table.insert( textChunks, preMatch );
		end
		table.insert( textChunks, Colors.white );
		table.insert( textChunks, matchText );
		table.insert( textChunks, Colors.rainCloudGrey );
		table.insert( textChunks, postMatch );
		table.insert( lines, { text = textChunks, command = match.command } );
	end
	return lines;
end

local getSuggestionsForArguments = function( self, input )
	local command = self._commands[input.command:lower()];
	if #command.args == 0 then
		return {};
	end
	local args = {};
	for i, commandArg in ipairs( command.args ) do
		local correctType;
		if input.arguments[i] then
			correctType = self:typeCheckArgument( command, i, input.arguments[i] );
		end
		local argString = ( i > 1 and " " or "" ) .. commandArg.name;
		local argColor = Colors.rainCloudGrey:alpha( 255 );
		if correctType == true then
			argColor = Colors.ecoGreen;
		elseif correctType == false then
			argColor = Colors.strawberry;
		end
		table.insert( args, argColor );
		table.insert( args, argString );
	end
	return {{ text = args }};
end

local updateSuggestions = function( self, input )
	local trimmedInput = trim( input.fullText );
	if #trimmedInput == 0 then
		self._suggestions = { lines = {}, state = "command" };
	elseif not input.commandIsComplete then
		self._suggestions = { lines = getSuggestionsForCommand( self, input ), state = "command" };
	elseif not self._commands[input.command:lower()] then
		self._suggestions = { lines = {{ text = { Colors.strawberry, input.command .. " is not a valid command" }}}, state = "badcommand" };
	else
		self._suggestions = { lines = getSuggestionsForArguments( self, input ), state = "args" };
	end
end



-- PUBLIC API

AutoComplete.init = function( self, commandDictionary )
	self._suggestions = { lines = {}, state = "command" };
	self._commands = commandDictionary;
end

AutoComplete.feedInput = function( self, parsedInput )
	assert( parsedInput.fullText );
	assert( parsedInput.command );
	assert( parsedInput.commandUntrimmed );
	assert( parsedInput.commandIsComplete ~= nil );
	assert( parsedInput.arguments );
	updateSuggestions( self, parsedInput );
end

AutoComplete.typeCheckArgument = function( self, command, argumentNumber, value )
	local requiredType = command.args[argumentNumber].type;
	if requiredType == "number" then
		return tonumber( value ) ~= nil;
	end
	if requiredType == "boolean" then
		return value == "0" or value == "1" or value == "true" or value == "false";
	end
	return true;
end

AutoComplete.getSuggestions = function( self )
	return self._suggestions;
end


return AutoComplete;