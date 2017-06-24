assert( gUnitTesting );
local AlignGoal = require( "src/ai/movement/AlignGoal" );
local Party = require( "src/persistence/Party" );
local MapScene = require( "src/scene/MapScene" );
local Entity = require( "src/scene/entity/Entity" );

local tests = {};

tests[#tests + 1] = { name = "Get position" };
tests[#tests].body = function()
	local party = Party:new();
	local scene = MapScene:new( "assets/map/test/empty.lua", party );
	
	local me = Entity:new( scene );
	me:addPhysicsBody();
	me:setPosition( 1, .5 );
	
	local target = Entity:new( scene );
	target:addPhysicsBody();
	target:setPosition( 0, 0 );
	
	local goal = AlignGoal:new( me, target, 1 );
	local x, y = goal:getPosition();
	assert( x == 1 );
	assert( y == 0 );
end

tests[#tests + 1] = { name = "Accept" };
tests[#tests].body = function()
	local party = Party:new();
	local scene = MapScene:new( "assets/map/test/empty.lua", party );
	
	local me = Entity:new( scene );
	me:addPhysicsBody();
	me:setPosition( 1, .5 );
	
	local target = Entity:new( scene );
	target:addPhysicsBody();
	target:setPosition( 0, 0 );
	
	local goal = AlignGoal:new( me, target, 1 );
	assert( goal:isPositionAcceptable( 0, 5 ) );
	assert( goal:isPositionAcceptable( 0, -5 ) );
	assert( goal:isPositionAcceptable( 5, 0 ) );
	assert( goal:isPositionAcceptable( -5, 0 ) );
	assert( goal:isPositionAcceptable( 0, .5 ) );
end

tests[#tests + 1] = { name = "Reject" };
tests[#tests].body = function()
	local party = Party:new();
	local scene = MapScene:new( "assets/map/test/empty.lua", party );
	
	local me = Entity:new( scene );
	me:addPhysicsBody();
	me:setPosition( 1, .5 );
	
	local target = Entity:new( scene );
	target:addPhysicsBody();
	target:setPosition( 0, 0 );
	
	local goal = AlignGoal:new( me, target, 1 );
	assert( not goal:isPositionAcceptable( 2, 2 ) );
	assert( not goal:isPositionAcceptable( -1.5, 1.5 ) );
end

return tests;
