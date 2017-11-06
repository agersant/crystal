assert( gConf.unitTesting );
local EntityGoal = require( "src/ai/movement/EntityGoal" );
local Party = require( "src/persistence/Party" );
local MapScene = require( "src/scene/MapScene" );
local Entity = require( "src/scene/entity/Entity" );

local tests = {};

tests[#tests + 1] = { name = "Get position" };
tests[#tests].body = function()
	local party = Party:new();
	local scene = MapScene:new( "assets/map/test/empty.lua", party );
	local target = Entity:new( scene );
	target:addPhysicsBody();
	target:setPosition( 8, 12 );
	local goal = EntityGoal:new( target, 1 );
	local x, y = goal:getPosition();
	assert( x == 8 );
	assert( y == 12 );
end

tests[#tests + 1] = { name = "Accept" };
tests[#tests].body = function()
local party = Party:new();
	local scene = MapScene:new( "assets/map/test/empty.lua", party );
	local target = Entity:new( scene );
	target:addPhysicsBody();
	target:setPosition( 8, 12 );
	local goal = EntityGoal:new( target, 1 );
	local x, y = goal:getPosition();
	assert( goal:isPositionAcceptable( 8.5, 11.8 ) );
end

tests[#tests + 1] = { name = "Reject" };
tests[#tests].body = function()
	local party = Party:new();
	local scene = MapScene:new( "assets/map/test/empty.lua", party );
	local target = Entity:new( scene );
	target:addPhysicsBody();
	target:setPosition( 8, 12 );
	local goal = EntityGoal:new( target, 1 );
	local x, y = goal:getPosition();
	assert( not goal:isPositionAcceptable( 10, 10 ) );
end

return tests;