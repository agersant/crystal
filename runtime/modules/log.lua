---@alias LogLevel "debug" | "info" | "warning" | "error" | "fatal"

local priorities = {
	debug = 0,
	info = 1,
	warning = 2,
	error = 3,
	fatal = 4,
};

---@class Logger
---@field private verbosity LogLevel
---@field private file_handle love.File
local Logger = Class("Logger");

Logger.init = function(self)
	self.verbosity = "debug";
	self.file_handle = nil;
end

Logger.create_log_file = function(self)
	local buffer_size = 1024; -- in bytes
	local log_directory = "logs";

	local error_message;
	local success = love.filesystem.createDirectory(log_directory);
	if not success then
		error("Could not create logs directory");
	end

	local now = tostring(os.time());
	local log_file = log_directory .. "/" .. now .. ".log";
	self.file_handle, error_message = love.filesystem.newFile(log_file, "w");
	if not self.file_handle then
		error(error_message);
	end

	success, error_message = self.file_handle:setBuffer("full", buffer_size);
	if not success then
		error(error_message);
	end
end

---@param verbosity LogLevel
Logger.set_verbosity = function(self, verbosity)
	assert(verbosity);
	assert(priorities[verbosity]);
	self.verbosity = verbosity;
end

---@param level LogLevel
---@param text string
Logger.append = function(self, level, text)
	assert(level);
	assert(priorities[level]);
	if priorities[level] < priorities[self.verbosity] then
		return;
	end
	local now = os.date();
	print(text);
	assert(self.file_handle);
	self.file_handle:write(tostring(now));
	self.file_handle:write(" > ");
	self.file_handle:write(level:upper());
	self.file_handle:write(" > ");
	self.file_handle:write(tostring(text));
	self.file_handle:write("\r\n");
end

local logger = Logger:new();

return {
	module_api = {
		debug = function(text)
			logger:append("debug", text);
		end,
		error = function(text)
			logger:append("error", text);
		end,
		fatal = function(text)
			logger:append("fatal", text);
		end,
		info = function(text)
			logger:append("info", text);
		end,
		set_verbosity = function(verbosity)
			logger:set_verbosity(verbosity);
		end,
		warning = function(text)
			logger:append("warning", text);
		end,
	},
	start = function()
		logger:create_log_file();
	end,
	-- TODO.hot_reload pick up same file after hot reload
};
