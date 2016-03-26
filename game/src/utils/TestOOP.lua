assert( gUnitTesting );
local OOP = require( "src/utils/OOP" );

local tests = {};

tests[#tests + 1] = { name = "To string" };
tests[#tests].body = function()
	local Fruit = Class( "Fruit" );
	local Peach = Class( "Peach", Fruit );
	local Bird = Class( "Bird" );
	assert( tostring( Fruit ) );
	assert( #tostring( Fruit ) > 0 );
	assert( tostring( Fruit ) ~= tostring( Bird ) );
	assert( tostring( Fruit ) ~= tostring( Peach ) );
end

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

tests[#tests + 1] = { name = "Get by name" };
tests[#tests].body = function()
	local Fruit = Class( "Fruit" );
	local Peach = Class( "Peach", Fruit );
	assert( Class:getByName( "Fruit" ) == Fruit );
	assert( Class:getByName( "Peach" ) == Peach );
	assert( Class:getByName( "Berry" ) == nil );
end

return tests;
