require( "src/utils/OOP" );

local bufferSize = 1024; -- in bytes
local logDir = "logs";

local Log = Class( "Log" );

if not gConf.features.logging then
	disableFeature( Log );
end

local append = function( self, level, text )
	assert( self._fileHandle );
	local now = os.date();
	print( text );
	self._fileHandle:write( tostring( now ) );
	self._fileHandle:write( " > " );
	self._fileHandle:write( level );
	self._fileHandle:write( " > " );
	self._fileHandle:write( tostring( text ) );
	self._fileHandle:write( "\r\n" );
end



-- PUBLIC API

Log.init = function( self )
	local errorMessage;
	local success = love.filesystem.createDirectory( logDir );
	if not success then
		error( "Could not create logs directory" );
	end

	
	local now = tostring( os.time() );
	local logFile = logDir .. "/crystal_" .. "_" .. now .. ".log";
	self._fileHandle, errorMessage = love.filesystem.newFile( logFile, "w" );
	if not self._fileHandle then
		error( errorMessage );
	end
	
	success, errorMessage = self._fileHandle:setBuffer( "full", bufferSize );
	if not success then
		error( errorMessage );
	end
	
	self:info( "Initialized log system" );
end

Log.debug = function( self, text )
	append( self, "DEBUG", text );
end

Log.info = function( self, text )
	append( self, "INFO", text );
end

Log.warning = function( self, text )
	append( self, "WARNING", text );
end

Log.error = function( self, text )
	append( self, "ERROR", text );
end

Log.fatal = function( self, text )
	append( self, "FATAL", text );
end



local instance = Log:new();
return instance;
