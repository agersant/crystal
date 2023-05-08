local features = require(CRYSTAL_RUNTIME .. "/features");

local channel_name = "hot_reload_channel";
local channel = love.thread.getChannel(channel_name);

return {
	begin_file_watch = function(crystal_root)
		if features.hot_reload then
			local thread = love.thread.newThread(CRYSTAL_RUNTIME .. "/modules/hot_reload/file_watch.lua");
			thread:start(channel_name, crystal_root);
		end
	end,
	consume_hot_reload = function()
		if not features.hot_reload then
			return false;
		end
		if channel:getCount() > 0 then
			channel:clear();
			return true;
		end
		return false;
	end
};
