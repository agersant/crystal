assert( gConf.unitTesting );
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

tests[#tests + 1] = { name = "Get class name" };
tests[#tests].body = function()
	local Fruit = Class( "Fruit" );
	local Peach = Class( "Peach", Fruit );
	local myFruit = Fruit:new();
	local myPeach = Peach:new();
	assert( myFruit:getClassName() == "Fruit" );
	assert( myPeach:getClassName() == "Peach" );
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
	local Apple = Class( "Apple", Fruit );

	local myPeach = Peach:new();
	assert( myPeach:isInstanceOf( Fruit ) );
	assert( myPeach:isInstanceOf( Peach ) );
	assert( not myPeach:isInstanceOf( Apple ) );

	local myFruit = Fruit:new();
	assert( myFruit:isInstanceOf( Fruit ) );
	assert( not myFruit:isInstanceOf( Peach ) );
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
