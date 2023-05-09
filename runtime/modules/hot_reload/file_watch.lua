require("love.timer");

local channel_name = ...;
local save_directory = love.filesystem.getSaveDirectory();
local mod_times = {};

local scan = function()
	local directories = { "" };
	while next(directories) do
		local directory = table.remove(directories);
		for _, item in ipairs(love.filesystem.getDirectoryItems(directory)) do
			local path = (directory == "") and item or (directory .. "/" .. item);
			local is_save_data = love.filesystem.getRealDirectory(path) == save_directory;
			if not is_save_data then
				local info = love.filesystem.getInfo(path);
				if info then
					local previous_mod_time = mod_times[path];
					mod_times[path] = info.modtime;
					if previous_mod_time and previous_mod_time ~= mod_times[path] then
						mod_times = {};
						love.thread.getChannel(channel_name):supply(true);
						return;
					elseif info.type == "directory" then
						table.insert(directories, path);
					end
				end
			end
		end
	end
end

while true do
	love.timer.sleep(0.05);
	scan();
end
