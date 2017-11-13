assert( gConf.unitTesting );
local Party = require( "src/persistence/Party" );
local MapScene = require( "src/scene/MapScene" );
local Script = require( "src/scene/Script" );
local InputDrivenController = require( "src/scene/controller/InputDrivenController" );
local Entity = require( "src/scene/entity/Entity" );
local Dialog = require( "src/ui/hud/Dialog" );

local tests = {};



tests[#tests + 1] = { name = "Blocks script during say" };
tests[#tests].body = function()
	local party = Party:new();
	local scene = MapScene:new( "assets/map/test/empty.lua", party );
	local player = Entity:new( scene );
	player:addScriptRunner();
	local controller = InputDrivenController:new( player, function() end, 1 );
	player:addController( controller );

	local dialog = Dialog:new();
	local a = 0;
	local script = Script:new( function( self )
		a = 1;
		dialog:open( self, player );
		dialog:say( "Test dialog." );
		a = 2;
	end	);
	script:update( 0 );
	assert( a == 1 );
	dialog:signal( "+advanceDialog" );
	dialog:signal( "+advanceDialog" );
	script:update( 0 );
	assert( a == 2 );
end



return tests;