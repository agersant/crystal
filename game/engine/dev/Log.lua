require("engine/utils/OOP");
local Features = require("engine/dev/Features");
local LogLevels = require("engine/dev/LogLevels");

local bufferSize = 1024; -- in bytes
local logDir = "logs";

local logLevelDetails = {
	[LogLevels.DEBUG] = {name = "DEBUG"},
	[LogLevels.INFO] = {name = "INFO"},
	[LogLevels.WARNING] = {name = "WARNING"},
	[LogLevels.ERROR] = {name = "ERROR"},
	[LogLevels.FATAL] = {name = "FATAL"},
};

local Log = Class("Log");

if not Features.logging then
	Features.stub(Log);
end

local append = function(self, level, text)
	assert(self._fileHandle);
	if level < self._verbosity then
		return;
	end
	local now = os.date();
	print(text);
	self._fileHandle:write(tostring(now));
	self._fileHandle:write(" > ");
	self._fileHandle:write(logLevelDetails[level].name);
	self._fileHandle:write(" > ");
	self._fileHandle:write(tostring(text));
	self._fileHandle:write("\r\n");
end

-- PUBLIC API

Log.init = function(self)
	self._verbosity = LogLevels.DEBUG;

	local errorMessage;
	local success = love.filesystem.createDirectory(logDir);
	if not success then
		error("Could not create logs directory");
	end

	local now = tostring(os.time());
	local logFile = logDir .. "/crystal_" .. "_" .. now .. ".log";
	self._fileHandle, errorMessage = love.filesystem.newFile(logFile, "w");
	if not self._fileHandle then
		error(errorMessage);
	end

	success, errorMessage = self._fileHandle:setBuffer("full", bufferSize);
	if not success then
		error(errorMessage);
	end
end

Log.setVerbosity = function(self, verbosity)
	assert(verbosity);
	assert(verbosity >= LogLevels.DEBUG);
	assert(verbosity <= LogLevels.FATAL);
	self._verbosity = verbosity;
end

Log.debug = function(self, text)
	append(self, LogLevels.DEBUG, text);
end

Log.info = function(self, text)
	append(self, LogLevels.INFO, text);
end

Log.warning = function(self, text)
	append(self, LogLevels.WARNING, text);
end

Log.error = function(self, text)
	append(self, LogLevels.ERROR, text);
end

Log.fatal = function(self, text)
	append(self, LogLevels.FATAL, text);
end

local instance = Log:new();
return instance;
