if gConf.unitTesting then
	require( "src/dev/mock/love/graphics" );
	local TestSuite = require( "src/TestSuite" );
	local success = TestSuite.execute();
	love.event.quit( success and 0 or 1 );
else
	require( "src/Game" );
end
