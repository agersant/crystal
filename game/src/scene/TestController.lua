assert( gUnitTesting );
local Controller = require( "src/scene/Controller" );

local tests = {};

tests[#tests + 1] = { name = "Script runs" };
tests[#tests].body = function()
	local a = 0;
	local controller = Controller:new( {}, function()
		a = a + 1;
	end	);
	assert( a == 0 );
	controller:update( 0 );
	assert( a == 1 );
	controller:update( 0 );
	assert( a == 1 );
end

tests[#tests + 1] = { name = "Wait frame" };
tests[#tests].body = function()
	local a = 0;
	local controller = Controller:new( {}, function( self )
		self:waitFrame();
		a = a + 1;
	end	);
	controller:update( 0 );
	assert( a == 0 );
	controller:update( 0 );
	assert( a == 1 );
end

tests[#tests + 1] = { name = "Wait duration" };
tests[#tests].body = function()
	local a = 0;
	local controller = Controller:new( {}, function( self )
		self:wait( 1 );
		a = a + 1;
	end	);
	controller:update( 0 );
	controller:update( 0.5 );
	assert( a == 0 );
	controller:update( 0.5 );
	assert( a == 1 );
end

tests[#tests + 1] = { name = "Wait for" };
tests[#tests].body = function()
	local a = 0;
	local controller = Controller:new( {}, function( self )
		self:waitFor( "testSignal" );
		a = a + 1;
	end	);
	controller:update( 0 );
	assert( a == 0 );
	controller:signal( "testSignal" );
	assert( a == 1 );
end

tests[#tests + 1] = { name = "Successive wait for" };
tests[#tests].body = function()
	local a = 0;
	local controller = Controller:new( {}, function( self )
		self:waitFor( "test1" );
		a = 1;
		self:waitFor( "test2" );
		a = 2;
	end	);
	controller:update( 0 );
	assert( a == 0 );
	controller:signal( "test1" );
	assert( a == 1 );
	controller:update( 0 );
	assert( a == 1 );
	controller:signal( "test2" );
	assert( a == 2 );
end

tests[#tests + 1] = { name = "Wait for any" };
tests[#tests].body = function()
	local a = 0;
	local controller = Controller:new( {}, function( self )
		self:waitForAny( { "testSignal", "gruik" } );
		a = a + 1;
	end	);
	controller:update( 0 );
	assert( a == 0 );
	controller:signal( "randomSignal" );
	assert( a == 0 );
	controller:signal( "gruik" );
	assert( a == 1 );
	controller:signal( "testSignal" );
	assert( a == 1 );
end

tests[#tests + 1] = { name = "Start thread" };
tests[#tests].body = function()
	local a = 0;
	local controller = Controller:new( {}, function( self )
		self:thread( function( self )
			a = a + 1;
			self:waitFrame();
			a = a + 1;
		end );
		a = 3;
	end	);
	controller:update( 0 );
	assert( a == 3 );
	controller:update( 0 );
	assert( a == 4 );
	controller:update( 0 );
	assert( a == 4 );
end

tests[#tests + 1] = { name = "Signal additional data" };
tests[#tests].body = function()
	local a = 0;
	local controller = Controller:new( {}, function( self )
		a = self:waitFor( "testSignal" );
	end	);
	assert( a == 0 );
	controller:update( 0 );
	assert( a == 0 );
	controller:signal( "testSignal", 1 );
	assert( a == 1 );
end

tests[#tests + 1] = { name = "Multiple signals additional data" };
tests[#tests].body = function()
	local a = 0;
	local s = "";
	local controller = Controller:new( {}, function( self )
		s, a = self:waitForAny( { "testSignal", "gruik" } );
	end	);
	assert( a == 0 );
	controller:update( 0 );
	assert( a == 0 );
	controller:signal( "gruik", 1 );
	assert( s == "gruik" );
	assert( a == 1 );
end



return tests;