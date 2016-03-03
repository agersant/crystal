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

tests[#tests + 1] = { name = "Remove vertex" };
tests[#tests].body = function()
	local chain = MapCollisionChainData:new( false );
	chain:addVertex( 0, 0 );
	chain:addVertex( 1, 0 );
	chain:addVertex( 1, 1 );
	chain:addVertex( 0, 1 );
	chain:removeVertex( 4 );
	chain:removeVertex( 1 );
	assert( 2 == chain:getNumVertices() );
	assert( 1, 0 == chain:getVertex( 1 ) );
	assert( 1, 1 == chain:getVertex( 2 ) );
end

tests[#tests + 1] = { name = "Remove midpoints basic" };
tests[#tests].body = function()
	local chain = MapCollisionChainData:new( false );
	chain:addVertex( 0, 0 );
	chain:addVertex( 1, 0 );
	chain:addVertex( 2, 0 );
	chain:addVertex( 1, .5 );
	chain:removeMidPoints();
	assert( 3 == chain:getNumVertices() );
	assert( 0, 0 == chain:getVertex( 1 ) );
	assert( 2, 0 == chain:getVertex( 2 ) );
	assert( 1, .5 == chain:getVertex( 3 ) );
end

tests[#tests + 1] = { name = "Remove midpoints tiny chain" };
tests[#tests].body = function()
	local chain = MapCollisionChainData:new( false );
	chain:addVertex( 0, 0 );
	chain:addVertex( 1, 0 );
	chain:addVertex( 2, 0 );
	chain:removeMidPoints();
	assert( 2 == chain:getNumVertices() );
	assert( 0, 0 == chain:getVertex( 1 ) );
	assert( 2, 0 == chain:getVertex( 2 ) );
end

tests[#tests + 1] = { name = "Remove midpoints long line" };
tests[#tests].body = function()
	local chain = MapCollisionChainData:new( false );
	chain:addVertex( 0, 0 );
	chain:addVertex( 2, 0 );
	chain:addVertex( 1, 0 );
	chain:addVertex( 4, 0 );
	chain:addVertex( 3, 0 );
	chain:removeMidPoints();
	assert( 2 == chain:getNumVertices() );
	assert( 0, 0 == chain:getVertex( 1 ) );
	assert( 4, 0 == chain:getVertex( 2 ) );
end

tests[#tests + 1] = { name = "Remove midpoints around loop" };
tests[#tests].body = function()
	local chain = MapCollisionChainData:new( false );
	chain:addVertex( 1, 0 );
	chain:addVertex( 2, 0 );
	chain:addVertex( 1, .5 );
	chain:addVertex( 0, 0 );
	chain:removeMidPoints();
	assert( 3 == chain:getNumVertices() );
	assert( 2, 0 == chain:getVertex( 1 ) );
	assert( 1, .5 == chain:getVertex( 2 ) );
	assert( 0, 0 == chain:getVertex( 3 ) );
end

tests[#tests + 1] = { name = "Remove midpoints with null vectors" };
tests[#tests].body = function()
	local chain = MapCollisionChainData:new( false );
	chain:addVertex( 0, 0 );
	chain:addVertex( 1, 0 );
	chain:addVertex( 1, 0 );
	chain:addVertex( 2, 0 );
	chain:addVertex( 2, 0 );
	chain:addVertex( 2, 0 );
	chain:addVertex( 1, .5 );
	chain:removeMidPoints();
	assert( 3 == chain:getNumVertices() );
	assert( 0, 0 == chain:getVertex( 1 ) );
	assert( 2, 0 == chain:getVertex( 2 ) );
	assert( 1, .5 == chain:getVertex( 3 ) );
end

tests[#tests + 1] = { name = "Merge chains, match on new chain last segment" };
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
	assert( chainA:merge( chainB ) );
	
	assert( 4 == chainA:getNumVertices() );
	assert( 4 == chainA:getNumSegments() );
	assert( 0, 0 == chainA:getVertex( 1 ) );
	assert( 2, 0 == chainA:getVertex( 2 ) );
	assert( 2, 1 == chainA:getVertex( 3 ) );
	assert( 0, 1 == chainA:getVertex( 4 ) );
end

tests[#tests + 1] = { name = "Merge chains, match on new chain first segment" };
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
	assert( chainA:merge( chainB ) );
	
	assert( 4 == chainA:getNumVertices() );
	assert( 4 == chainA:getNumSegments() );
	assert( 0, 0 == chainA:getVertex( 1 ) );
	assert( 2, 0 == chainA:getVertex( 2 ) );
	assert( 2, 1 == chainA:getVertex( 3 ) );
	assert( 0, 1 == chainA:getVertex( 4 ) );
end

tests[#tests + 1] = { name = "Merge chains, match on new chain misc segment" };
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
	assert( chainA:merge( chainB ) );
	
	assert( 4 == chainA:getNumVertices() );
	assert( 4 == chainA:getNumSegments() );
	assert( 0, 0 == chainA:getVertex( 1 ) );
	assert( 2, 0 == chainA:getVertex( 2 ) );
	assert( 2, 1 == chainA:getVertex( 3 ) );
	assert( 0, 1 == chainA:getVertex( 4 ) );
end

tests[#tests + 1] = { name = "Merge chains reverse, match on new chain last segment" };
tests[#tests].body = function()
	local chainA = MapCollisionChainData:new( false );
	chainA:addVertex( 0, 0 );
	chainA:addVertex( 1, 0 );
	chainA:addVertex( 1, 1 );
	chainA:addVertex( 0, 1 );
	
	local chainB = MapCollisionChainData:new( false );
	chainB:addVertex( 1, 1 );
	chainB:addVertex( 2, 1 );
	chainB:addVertex( 2, 0 );
	chainB:addVertex( 1, 0 );
	assert( chainA:merge( chainB ) );
	
	assert( 4 == chainA:getNumVertices() );
	assert( 4 == chainA:getNumSegments() );
	assert( 0, 0 == chainA:getVertex( 1 ) );
	assert( 2, 0 == chainA:getVertex( 2 ) );
	assert( 2, 1 == chainA:getVertex( 3 ) );
	assert( 0, 1 == chainA:getVertex( 4 ) );
end

tests[#tests + 1] = { name = "Merge chains reverse, match on new chain first segment" };
tests[#tests].body = function()
	local chainA = MapCollisionChainData:new( false );
	chainA:addVertex( 0, 0 );
	chainA:addVertex( 1, 0 );
	chainA:addVertex( 1, 1 );
	chainA:addVertex( 0, 1 );
	
	local chainB = MapCollisionChainData:new( false );
	chainB:addVertex( 2, 1 );
	chainB:addVertex( 2, 0 );
	chainB:addVertex( 1, 0 );
	chainB:addVertex( 1, 1 );
	assert( chainA:merge( chainB ) );
	
	assert( 4 == chainA:getNumVertices() );
	assert( 4 == chainA:getNumSegments() );
	assert( 0, 0 == chainA:getVertex( 1 ) );
	assert( 2, 0 == chainA:getVertex( 2 ) );
	assert( 2, 1 == chainA:getVertex( 3 ) );
	assert( 0, 1 == chainA:getVertex( 4 ) );
end

tests[#tests + 1] = { name = "Merge chains reverse, match on new chain misc segment" };
tests[#tests].body = function()
	local chainA = MapCollisionChainData:new( false );
	chainA:addVertex( 0, 0 );
	chainA:addVertex( 1, 0 );
	chainA:addVertex( 1, 1 );
	chainA:addVertex( 0, 1 );
	
	local chainB = MapCollisionChainData:new( false );
	chainB:addVertex( 2, 0 );
	chainB:addVertex( 1, 0 );
	chainB:addVertex( 1, 1 );
	chainB:addVertex( 2, 1 );
	assert( chainA:merge( chainB ) );
	
	assert( 4 == chainA:getNumVertices() );
	assert( 4 == chainA:getNumSegments() );
	assert( 0, 0 == chainA:getVertex( 1 ) );
	assert( 2, 0 == chainA:getVertex( 2 ) );
	assert( 2, 1 == chainA:getVertex( 3 ) );
	assert( 0, 1 == chainA:getVertex( 4 ) );
end

tests[#tests + 1] = { name = "Merge chains, partial segment match" };
tests[#tests].body = function()
	local chainA = MapCollisionChainData:new( false );
	chainA:addVertex( 0, 0 );
	chainA:addVertex( 2, 0 );
	chainA:addVertex( 2, 1 );
	chainA:addVertex( 0, 1 );
	
	local chainB = MapCollisionChainData:new( false );
	chainB:addVertex( 0, 1 );
	chainB:addVertex( 1, 1 );
	chainB:addVertex( 1, 2 );
	chainB:addVertex( 0, 2 );
	assert( chainA:merge( chainB ) );
	
	assert( 6 == chainA:getNumVertices() );
	assert( 0, 0 == chainA:getVertex( 1 ) );
	assert( 2, 0 == chainA:getVertex( 2 ) );
	assert( 2, 1 == chainA:getVertex( 3 ) );
	assert( 1, 1 == chainA:getVertex( 4 ) );
	assert( 1, 2 == chainA:getVertex( 5 ) );
	assert( 0, 2 == chainA:getVertex( 6 ) );
end

tests[#tests + 1] = { name = "Merge chains, partial segment match slanted" };
tests[#tests].body = function()
	local chainA = MapCollisionChainData:new( false );
	chainA:addVertex( 0, 16 );
	chainA:addVertex( 16, 0 );
	chainA:addVertex( 32, 0 );
	chainA:addVertex( 48, 16 );
	
	local chainB = MapCollisionChainData:new( false );
	chainB:addVertex( 0, 16 );
	chainB:addVertex( 16, 16 );
	chainB:addVertex( 16, 32 );
	chainB:addVertex( 0, 32 );
	assert( chainA:merge( chainB ) );
	
	assert( 7 == chainA:getNumVertices() );
	assert( 0, 16 == chainA:getVertex( 1 ) );
	assert( 16, 0 == chainA:getVertex( 2 ) );
	assert( 32, 0 == chainA:getVertex( 3 ) );
	assert( 48, 16 == chainA:getVertex( 4 ) );
	assert( 16, 16 == chainA:getVertex( 5 ) );
	assert( 16, 32 == chainA:getVertex( 6 ) );
	assert( 0, 32 == chainA:getVertex( 7 ) );
end

tests[#tests + 1] = { name = "Merge chains, large triangle" };
tests[#tests].body = function()
	local chainA = MapCollisionChainData:new( false );
	chainA:addVertex( 1, 1 );
	chainA:addVertex( 2, 0 );
	chainA:addVertex( 2, 1 );
	
	local chainB = MapCollisionChainData:new( false );
	chainB:addVertex( 0, 2 );
	chainB:addVertex( 1, 1 );
	chainB:addVertex( 1, 2 );
	
	local chainC = MapCollisionChainData:new( false );
	chainC:addVertex( 1, 1 );
	chainC:addVertex( 2, 1 );
	chainC:addVertex( 2, 2 );
	chainC:addVertex( 1, 2 );
	assert( chainB:merge( chainC ) );
	assert( 4 == chainB:getNumVertices() );

	assert( chainA:merge( chainB ) );
	assert( 3 == chainA:getNumVertices() );
	assert( 2, 0 == chainA:getVertex( 1 ) );
	assert( 2, 2 == chainA:getVertex( 2 ) );
	assert( 0, 2 == chainA:getVertex( 3 ) );
end

tests[#tests + 1] = { name = "Merge chains, square shape (many partial segment matches)" };
tests[#tests].body = function()
	-- TL
	local chainA = MapCollisionChainData:new( false );
	chainA:addVertex( 0, 0 );
	chainA:addVertex( 1, 0 );
	chainA:addVertex( 1, 1 );
	chainA:addVertex( 0, 1 );
	
	-- T
	local chainB = MapCollisionChainData:new( false );
	chainB:addVertex( 1, 0 );
	chainB:addVertex( 2, 0 );
	chainB:addVertex( 2, 1 );
	chainB:addVertex( 1, 1 );
	assert( chainA:merge( chainB ) );
	assert( 4 == chainA:getNumVertices() );
	
	-- TR
	local chainB = MapCollisionChainData:new( false );
	chainB:addVertex( 2, 0 );
	chainB:addVertex( 3, 0 );
	chainB:addVertex( 3, 1 );
	chainB:addVertex( 2, 1 );
	assert( chainA:merge( chainB ) );
	assert( 4 == chainA:getNumVertices() );
	
	-- L
	local chainB = MapCollisionChainData:new( false );
	chainB:addVertex( 0, 1 );
	chainB:addVertex( 1, 1 );
	chainB:addVertex( 1, 2 );
	chainB:addVertex( 0, 2 );
	assert( chainA:merge( chainB ) );
	assert( 6 == chainA:getNumVertices() );
	
	-- R
	local chainB = MapCollisionChainData:new( false );
	chainB:addVertex( 2, 1 );
	chainB:addVertex( 3, 1 );
	chainB:addVertex( 3, 2 );
	chainB:addVertex( 2, 2 );
	assert( chainA:merge( chainB ) );
	assert( 8 == chainA:getNumVertices() );
	
	-- BL
	local chainB = MapCollisionChainData:new( false );
	chainB:addVertex( 0, 2 );
	chainB:addVertex( 1, 2 );
	chainB:addVertex( 1, 3 );
	chainB:addVertex( 0, 3 );
	assert( chainA:merge( chainB ) );
	assert( 8 == chainA:getNumVertices() );
	
	-- B
	local chainB = MapCollisionChainData:new( false );
	chainB:addVertex( 1, 2 );
	chainB:addVertex( 2, 2 );
	chainB:addVertex( 2, 3 );
	chainB:addVertex( 1, 3 );
	assert( chainA:merge( chainB ) );
	assert( 10 == chainA:getNumVertices() );
	
	-- BR
	local chainB = MapCollisionChainData:new( false );
	chainB:addVertex( 2, 2 );
	chainB:addVertex( 3, 2 );
	chainB:addVertex( 3, 3 );
	chainB:addVertex( 2, 3 );
	assert( chainA:merge( chainB ) );
	assert( 10 == chainA:getNumVertices() );
	
	assert( 10 == chainA:getNumVertices() );
	assert( 0, 0 == chainA:getVertex( 1 ) );
	assert( 3, 0 == chainA:getVertex( 2 ) );
	assert( 3, 3 == chainA:getVertex( 3 ) );
	assert( 2, 3 == chainA:getVertex( 4 ) );
	assert( 2, 1 == chainA:getVertex( 5 ) );
	assert( 1, 1 == chainA:getVertex( 6 ) );
	assert( 1, 2 == chainA:getVertex( 7 ) );
	assert( 2, 2 == chainA:getVertex( 8 ) );
	assert( 2, 3 == chainA:getVertex( 9 ) );
	assert( 0, 3 == chainA:getVertex( 10 ) );
end



return tests;
