local Features = require("dev/Features");

local bufferSize = 1024; -- in bytes
local logDir = "logs";

local Log = Class("Log");

Log.Levels = { DEBUG = 1, INFO = 2, WARNING = 3, ERROR = 4, FATAL = 5 };

local logLevelDetails = {
	[Log.Levels.DEBUG] = { name = "DEBUG" },
	[Log.Levels.INFO] = { name = "INFO" },
	[Log.Levels.WARNING] = { name = "WARNING" },
	[Log.Levels.ERROR] = { name = "ERROR" },
	[Log.Levels.FATAL] = { name = "FATAL" },
};

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

Log.init = function(self)
	self._verbosity = Log.Levels.DEBUG;

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
	assert(verbosity >= Log.Levels.DEBUG);
	assert(verbosity <= Log.Levels.FATAL);
	self._verbosity = verbosity;
end

Log.debug = function(self, text)
	append(self, Log.Levels.DEBUG, text);
end

Log.info = function(self, text)
	append(self, Log.Levels.INFO, text);
end

Log.warning = function(self, text)
	append(self, Log.Levels.WARNING, text);
end

Log.error = function(self, text)
	append(self, Log.Levels.ERROR, text);
end

Log.fatal = function(self, text)
	append(self, Log.Levels.FATAL, text);
end

return Log;
