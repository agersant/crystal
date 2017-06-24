if gConf.unitTesting then
	local TestSuite = require( "src/TestSuite" );
	local success = TestSuite.execute();
	love.event.quit( success and 0 or 1 );
else
	require( "src/Game" );
end