assert( gUnitTesting );
local Controller = require( "src/scene/controller/Controller" );
local Script = require( "src/scene/controller/Script" );
local Entity = require( "src/scene/entity/Entity" );
local Scene = require( "src/scene/Scene" );

local tests = {};

tests[#tests + 1] = { name = "Script runs" };
tests[#tests].body = function()
	local a = 0;
	local entity = Entity:new( Scene:new() );
	local script = Script:new( entity, function( self )
		a = a + 1;
	end	);
	assert( a == 0 );
	script:update( 0 );
	assert( a == 1 );
	script:update( 0 );
	assert( a == 1 );
end

tests[#tests + 1] = { name = "Wait frame" };
tests[#tests].body = function()
	local a = 0;
	local entity = Entity:new( Scene:new() );
	local script = Script:new( entity, function( self )
		self:waitFrame();
		a = a + 1;
	end	);
	script:update( 0 );
	assert( a == 0 );
	script:update( 0 );
	assert( a == 1 );
end

tests[#tests + 1] = { name = "Wait duration" };
tests[#tests].body = function()
	local a = 0;
	local entity = Entity:new( Scene:new() );
	local script = Script:new( entity, function( self )
		self:wait( 1 );
		a = a + 1;
	end	);
	script:update( 0 );
	script:update( 0.5 );
	assert( a == 0 );
	script:update( 0.5 );
	assert( a == 1 );
end

tests[#tests + 1] = { name = "Wait for" };
tests[#tests].body = function()
	local a = 0;
	local entity = Entity:new( Scene:new() );
	local script = Script:new( entity, function( self )
		self:waitFor( "testSignal" );
		a = a + 1;
	end	);
	script:update( 0 );
	assert( a == 0 );
	script:signal( "testSignal" );
	assert( a == 1 );
end

tests[#tests + 1] = { name = "Successive wait for" };
tests[#tests].body = function()
	local a = 0;
	local entity = Entity:new( Scene:new() );
	local script = Script:new( entity, function( self )
		self:waitFor( "test1" );
		a = 1;
		self:waitFor( "test2" );
		a = 2;
	end	);
	script:update( 0 );
	assert( a == 0 );
	script:signal( "test1" );
	assert( a == 1 );
	script:update( 0 );
	assert( a == 1 );
	script:signal( "test2" );
	assert( a == 2 );
end

tests[#tests + 1] = { name = "Wait for any" };
tests[#tests].body = function()
	local a = 0;
	local entity = Entity:new( Scene:new() );
	local script = Script:new( entity, function( self )
		self:waitForAny( { "testSignal", "gruik" } );
		a = a + 1;
	end	);
	script:update( 0 );
	assert( a == 0 );
	script:signal( "randomSignal" );
	assert( a == 0 );
	script:signal( "gruik" );
	assert( a == 1 );
	script:signal( "testSignal" );
	assert( a == 1 );
end

tests[#tests + 1] = { name = "Start thread" };
tests[#tests].body = function()
	local a = 0;
	local entity = Entity:new( Scene:new() );
	local script = Script:new( entity, function( self )
		local t = self:thread( function( self )
			self:waitFrame();
			a = 1;
		end );
		self:wait( 1 );
	end	);
	script:update( 0 );
	assert( a == 0 );
	script:update( 0 );
	assert( a == 1 );
end

tests[#tests + 1] = { name = "Stop thread" };
tests[#tests].body = function()
	local a = 0;
	local entity = Entity:new( Scene:new() );
	local script = Script:new( entity, function( self )
		local t = self:thread( function( self )
			self:waitFrame();
			a = 1;
		end );
		t:stop();
	end	);
	script:update( 0 );
	assert( a == 0 );
	script:update( 0 );
	assert( a == 0 );
end

tests[#tests + 1] = { name = "Signal additional data" };
tests[#tests].body = function()
	local a = 0;
	local entity = Entity:new( Scene:new() );
	local script = Script:new( entity, function( self )
		a = self:waitFor( "testSignal" );
	end	);
	assert( a == 0 );
	script:update( 0 );
	assert( a == 0 );
	script:signal( "testSignal", 1 );
	assert( a == 1 );
end

tests[#tests + 1] = { name = "Multiple signals additional data" };
tests[#tests].body = function()
	local a = 0;
	local s = "";
	local entity = Entity:new( Scene:new() );
	local script = Script:new( entity, function( self )
		s, a = self:waitForAny( { "testSignal", "gruik" } );
	end	);
	assert( a == 0 );
	script:update( 0 );
	assert( a == 0 );
	script:signal( "gruik", 1 );
	assert( s == "gruik" );
	assert( a == 1 );
end

tests[#tests + 1] = { name = "End on" };
tests[#tests].body = function()
	local a = 0;
	local entity = Entity:new( Scene:new() );
	local script = Script:new( entity, function( self )
		self:endOn( "end" );
		self:waitFrame();
		a = 1;
	end	);
	script:update( 0 );
	assert( a == 0 );
	script:signal( "end" );
	script:update( 0 );
	assert( a == 0 );
end

tests[#tests + 1] = { name = "Unblock after end on" };
tests[#tests].body = function()
	local a = 0;
	local entity = Entity:new( Scene:new() );
	local script = Script:new( entity, function( self )
		self:endOn( "end" );
		self:waitFor( "signal" );
		a = 1;
	end	);
	script:update( 0 );
	assert( a == 0 );
	script:signal( "end" );
	script:signal( "signal" );
	script:update( 0 );
	assert( a == 0 );
end

tests[#tests + 1] = { name = "End child threads after main thread ends" };
tests[#tests].body = function()
	local a = 0;
	local entity = Entity:new( Scene:new() );
	local script = Script:new( entity, function( self )
		self:thread( function() self:waitFrame(); a = 1; end );
	end	);
	script:update( 0 );
	assert( a == 0 );
	script:update( 0 );
	assert( a == 0 );
end



return tests;
