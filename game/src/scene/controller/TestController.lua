assert( gUnitTesting );
local Controller = require( "src/scene/controller/Controller" );
local Script = require( "src/scene/controller/Script" );
local Entity = require( "src/scene/entity/Entity" );
local Scene = require( "src/scene/Scene" );

local tests = {};

tests[#tests + 1] = { name = "Add script" };
tests[#tests].body = function()
	local a = 0;
	local controller = Controller:new( Entity:new( Scene:new() ) );
	local script = Script:new( controller, function( self )
		local controller = self:getController();
		local script = Script:new( controller, function( self )
			a = a + 1;
			self:waitFrame();
			a = a + 1;
		end );
		controller:addScript( script );
		a = 3;
	end );
	controller:addScript( script );
	assert( a == 0 );
	controller:update( 0 );
	assert( a == 3 );
	controller:update( 0 );
	assert( a == 4 );
	controller:update( 0 );
	assert( a == 4 );
end



return tests;
