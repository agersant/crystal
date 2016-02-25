gUnitTesting = true;
love = require( "src/dev/mock/Love" );

require( "Conf" );



local testFiles = {
	"src/dev/cli/TestCLI",
	"src/ui/TestTextInput",
	"src/utils/TestMapUtils",
	"src/utils/TestStringUtils",
};



local runTestFile = function( source )
	
	print( "" );
	local tests = require( source );
	print( "Running " .. #tests .. " tests from: " .. source );
	
	local numSuccess = 0;
	for i, test in ipairs( tests ) do
		assert( type( test.name ) == "string" );
		assert( type( test.body ) == "function" );
		local success, errorText = pcall( test.body );
		if success then
			numSuccess = numSuccess + 1;
			print( "    " .. test.name .. ": PASS" );
		else
			print( "    " .. test.name .. ": FAIL (see error output below)" );
			print( errorText );
		end
	end
	
	package.loaded[source] = false;
	return numSuccess, #tests;
	
end

local printResults = function( numSuccess, numTests )
	local successRate = numTests > 0 and numSuccess / numTests or 1;
	print( "" );
	print( "Grand total: " .. numSuccess .. "/" .. numTests .. " tests passed" );
end

local runTestSuite = function()
	local totalNumSuccess = 0;
	local totalNumTests = 0;
	for i, testFile in ipairs( testFiles ) do
		local numSuccess, numTests = runTestFile( testFile );
		totalNumSuccess = totalNumSuccess + numSuccess;
		totalNumTests = totalNumTests + numTests;
	end
	printResults( totalNumSuccess, totalNumTests );
	return totalNumSuccess == totalNumTests;
end



local success = runTestSuite();
os.exit( success, true );
