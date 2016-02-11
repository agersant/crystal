Log = {}; -- global

if not gConf.features.logging then
	disableFeature( Log );
end



local bufferSize = 1024; -- in bytes
local logDir = "logs";
local fileHandle = nil;

local append = function( level, text )
	assert( fileHandle );
	local now = os.date();
	print( text );
	fileHandle:write( tostring( now ) );
	fileHandle:write( " > " );
	fileHandle:write( level );
	fileHandle:write( " > " );
	fileHandle:write( tostring( text ) );
	fileHandle:write( "\r\n" );
end



-- PUBLIC API

Log.init = function()
	local errorMessage;
	local success = love.filesystem.createDirectory( logDir );
	if not success then
		error( "Could not create logs directory" );
	end

	
	local now = tostring( os.time() );
	local logFile = logDir .. "/crystal_" .. "_" .. now .. ".log";
	fileHandle, errorMessage = love.filesystem.newFile( logFile, "w" );
	if not fileHandle then
		error( errorMessage );
	end
	
	success, errorMessage = fileHandle:setBuffer( "full", bufferSize );
	if not success then
		error( errorMessage );
	end
	
	Log.info( "Initialized log system" );
end

Log.debug = function( text )
	append( "DEBUG", text );
end

Log.info = function( text )
	append( "INFO", text );
end

Log.warning = function( text )
	append( "WARNING", text );
end

Log.error = function( text )
	append( "ERROR", text );
end

Log.fatal = function( text )
	append( "FATAL", text );
end


return Log;