assert( gConf.unitTesting );
local CLI = require( "src/dev/cli/CLI" );

local tests = {};

local enableCLI = function()
	if not CLI:isActive() then
		CLI:toggle();
	end
end

tests[#tests + 1] = { name = "Toggling" };
tests[#tests].body = function()
	local wasActive = CLI:isActive();
	CLI:toggle();
	assert( CLI:isActive() ~= wasActive );
	CLI:toggle();
	assert( CLI:isActive() == wasActive );
end

tests[#tests + 1] = { name = "Run command" };
tests[#tests].body = function()
	enableCLI();
	local sentinel = 0;
	CLI:addCommand( "testCommand", function() sentinel = 1; end );
	CLI:textInput( "testCommand" );
	CLI:keyPressed( "return" );
	assert( sentinel == 1 );
	CLI:removeCommand( "testCommand" );
end

tests[#tests + 1] = { name = "Number argument" };
tests[#tests].body = function()
	enableCLI();
	local sentinel = 0;
	CLI:addCommand( "testCommand value:number", function( value ) sentinel = value; end );
	CLI:textInput( "testCommand 2" );
	CLI:keyPressed( "return" );
	assert( sentinel == 2 );
	CLI:removeCommand( "testCommand" );
end

tests[#tests + 1] = { name = "String argument" };
tests[#tests].body = function()
	enableCLI();
	local sentinel = "";
	CLI:addCommand( "testCommand value:string", function( value ) sentinel = value; end );
	CLI:textInput( "testCommand oink" );
	CLI:keyPressed( "return" );
	assert( sentinel == "oink" );
	CLI:removeCommand( "testCommand" );
end

tests[#tests + 1] = { name = "Execute from code" };
tests[#tests].body = function()
	local sentinel = "";
	CLI:addCommand( "testCommand value:string", function( value ) sentinel = value; end );
	CLI:execute( "testCommand oink" );
	assert( sentinel == "oink" );
	CLI:removeCommand( "testCommand" );
end

tests[#tests + 1] = { name = "Execute from history" };
tests[#tests].body = function()
	local sentinel = "";
	CLI:addCommand( "testCommand value:string", function( value ) sentinel = value; end );

	CLI:textInput( "testCommand oink" );
	CLI:keyPressed( "return" );
	assert( sentinel == "oink" );

	CLI:keyPressed( "up" );
	CLI:textInput( "k" );
	CLI:keyPressed( "return" );
	assert( sentinel == "oinkk" );

	CLI:keyPressed( "up" );
	CLI:keyPressed( "up" );
	CLI:keyPressed( "return" );
	assert( sentinel == "oink" );

	CLI:removeCommand( "testCommand" );
end

tests[#tests + 1] = { name = "Autocomplete" };
tests[#tests].body = function()
	local sentinel = "";
	CLI:addCommand( "testCommand", function( value ) sentinel = "oink"; end );
	CLI:textInput( "testcomm" );
	CLI:keyPressed( "tab" );
	CLI:keyPressed( "return" );
	assert( sentinel == "oink" );
	CLI:removeCommand( "testCommand" );
end



return tests;
