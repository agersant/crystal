assert( gUnitTesting );
local OOP = require( "src/utils/OOP" );

local tests = {};

tests[#tests + 1] = { name = "Is instance of" };
tests[#tests].body = function()
	local Fruit = Class( "Fruit" );
	local myFruit = Fruit:new();
	assert( myFruit:isInstanceOf( Fruit ) );
	
	local Bird = Class( "Bird" );
	assert( not myFruit:isInstanceOf( Bird ) );
end

tests[#tests + 1] = { name = "Is instance of inheritance" };
tests[#tests].body = function()
	local Fruit = Class( "Fruit" );
	local Peach = Class( "Peach", Fruit );
	local myFruit = Peach:new();
	assert( myFruit:isInstanceOf( Fruit ) );
	assert( myFruit:isInstanceOf( Peach ) );
end

return tests;
