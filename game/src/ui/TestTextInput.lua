local TextInput = require( "src/ui/TextInput" );

local tests = {};

tests[#tests + 1] = {
	name = "Setting and clearing text", 
	body = function()
		local textInput = TextInput:new();
		assert( textInput:getText() == "" );
		textInput:setText( "oink" );
		assert( textInput:getText() == "oink" );
		textInput:clear();
		assert( textInput:getText() == "" );
	end
};

tests[#tests + 1] = {
	name = "Text entry", 
	body = function()
		local textInput = TextInput:new();
		textInput:setText( "oink" );
		textInput:textInput( "g" );
		textInput:textInput( "r" );
		textInput:textInput( "u" );
		textInput:textInput( "i" );
		textInput:textInput( "k" );
		assert( textInput:getText() == "oinkgruik" );
	end
};

return tests;