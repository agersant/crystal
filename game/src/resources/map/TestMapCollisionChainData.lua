assert( gUnitTesting );
local MapCollisionChainData = require( "src/resources/map/MapCollisionChainData" );

local tests = {};

tests[#tests + 1] = { name = "Count vertices" };
tests[#tests].body = function()
	local chain = MapCollisionChainData:new( false );
	assert( chain:getNumVertices() == 0 );
	chain:addVertex( 0, 0 );
	assert( chain:getNumVertices() == 1 );
	chain:addVertex( 1, 0 );
	assert( chain:getNumVertices() == 2 );
	chain:addVertex( 1, 1 );
	assert( chain:getNumVertices() == 3 );
end

tests[#tests + 1] = { name = "Count segments" };
tests[#tests].body = function()
	local chain = MapCollisionChainData:new( false );
	assert( chain:getNumSegments() == 0 );
	chain:addVertex( 0, 0 );
	assert( chain:getNumSegments() == 0 );
	chain:addVertex( 1, 0 );
	assert( chain:getNumSegments() == 1 );
	chain:addVertex( 1, 1 );
	assert( chain:getNumSegments() == 3 );
	chain:addVertex( 0, 1 );
	assert( chain:getNumSegments() == 4 );
	chain:addVertex( 0.2, 0.5 );
	assert( chain:getNumSegments() == 5 );
end

tests[#tests + 1] = { name = "Retrieve vertex" };
tests[#tests].body = function()
	local chain = MapCollisionChainData:new( false );
	chain:addVertex( 0, 0 );
	chain:addVertex( 1, 0 );
	chain:addVertex( 1, 1 );
	chain:addVertex( 0, 1 );
	assert( 0, 0 == chain:getVertex( 1 ) );
	assert( 1, 0 == chain:getVertex( 2 ) );
	assert( 1, 1 == chain:getVertex( 3 ) );
	assert( 0, 1 == chain:getVertex( 4 ) );
end

tests[#tests + 1] = { name = "Retrieve segment" };
tests[#tests].body = function()
	local chain = MapCollisionChainData:new( false );
	chain:addVertex( 0, 0 );
	chain:addVertex( 1, 0 );
	chain:addVertex( 1, 1 );
	chain:addVertex( 0, 1 );
	assert( 0, 0, 1, 0 == chain:getSegment( 1 ) );
	assert( 1, 0, 1, 1 == chain:getSegment( 2 ) );
	assert( 1, 1, 0, 1 == chain:getSegment( 3 ) );
	assert( 0, 1, 0, 0 == chain:getSegment( 4 ) );
end

tests[#tests + 1] = { name = "Insert vertex" };
tests[#tests].body = function()
	local chain = MapCollisionChainData:new( false );
	chain:insertVertex( 1, 0, 1 );
	assert( 1, 0 == chain:getVertex( 1 ) );
	chain:insertVertex( 0, 0, 1 );
	assert( 0, 0 == chain:getVertex( 1 ) );
	assert( 1, 0 == chain:getVertex( 2 ) );
	chain:insertVertex( 1, 1, 3 );
	assert( 0, 0 == chain:getVertex( 1 ) );
	assert( 1, 0 == chain:getVertex( 2 ) );
	assert( 1, 1 == chain:getVertex( 3 ) );
end

tests[#tests + 1] = { name = "Replace segment by chain, match on new chain last segment" };
tests[#tests].body = function()

	local chainA = MapCollisionChainData:new( false );
	chainA:addVertex( 0, 0 );
	chainA:addVertex( 1, 0 );
	chainA:addVertex( 1, 1 );
	chainA:addVertex( 0, 1 );
	
	local chainB = MapCollisionChainData:new( false );
	chainB:addVertex( 1, 0 );
	chainB:addVertex( 2, 0 );
	chainB:addVertex( 2, 1 );
	chainB:addVertex( 1, 1 );
	
	chainA:replaceSegmentByChain( 2, 4, chainB, true );
	
	assert( 6 == chainA:getNumVertices() );
	assert( 6 == chainA:getNumSegments() );
	assert( 0, 0 == chainA:getVertex( 1 ) );
	assert( 1, 0 == chainA:getVertex( 2 ) );
	assert( 2, 0 == chainA:getVertex( 3 ) );
	assert( 2, 1 == chainA:getVertex( 4 ) );
	assert( 1, 1 == chainA:getVertex( 5 ) );
	assert( 0, 1 == chainA:getVertex( 6 ) );
end

tests[#tests + 1] = { name = "Replace segment by chain, match on new chain first segment" };
tests[#tests].body = function()

	local chainA = MapCollisionChainData:new( false );
	chainA:addVertex( 0, 0 );
	chainA:addVertex( 1, 0 );
	chainA:addVertex( 1, 1 );
	chainA:addVertex( 0, 1 );
	
	local chainB = MapCollisionChainData:new( false );
	chainB:addVertex( 1, 1 );
	chainB:addVertex( 1, 0 );
	chainB:addVertex( 2, 0 );
	chainB:addVertex( 2, 1 );
	
	chainA:replaceSegmentByChain( 2, 1, chainB, true );
	
	assert( 6 == chainA:getNumVertices() );
	assert( 6 == chainA:getNumSegments() );
	assert( 0, 0 == chainA:getVertex( 1 ) );
	assert( 1, 0 == chainA:getVertex( 2 ) );
	assert( 2, 0 == chainA:getVertex( 3 ) );
	assert( 2, 1 == chainA:getVertex( 4 ) );
	assert( 1, 1 == chainA:getVertex( 5 ) );
	assert( 0, 1 == chainA:getVertex( 6 ) );
end

tests[#tests + 1] = { name = "Replace segment by chain, match on new chain misc segment" };
tests[#tests].body = function()

	local chainA = MapCollisionChainData:new( false );
	chainA:addVertex( 0, 0 );
	chainA:addVertex( 1, 0 );
	chainA:addVertex( 1, 1 );
	chainA:addVertex( 0, 1 );
	
	local chainB = MapCollisionChainData:new( false );
	chainB:addVertex( 2, 1 );
	chainB:addVertex( 1, 1 );
	chainB:addVertex( 1, 0 );
	chainB:addVertex( 2, 0 );
	
	chainA:replaceSegmentByChain( 2, 2, chainB, true );
	
	assert( 6 == chainA:getNumVertices() );
	assert( 6 == chainA:getNumSegments() );
	assert( 0, 0 == chainA:getVertex( 1 ) );
	assert( 1, 0 == chainA:getVertex( 2 ) );
	assert( 2, 0 == chainA:getVertex( 3 ) );
	assert( 2, 1 == chainA:getVertex( 4 ) );
	assert( 1, 1 == chainA:getVertex( 5 ) );
	assert( 0, 1 == chainA:getVertex( 6 ) );
end



return tests;
