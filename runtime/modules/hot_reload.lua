local features = require(CRYSTAL_RUNTIME .. "/features");

local channel_name = "hot_reload_channel";
local channel = love.thread.getChannel(channel_name);

local persistence = {};

local enabled = true;
crystal.cmd.add("enableHotReload", function() enabled = true end);
crystal.cmd.add("disableHotReload", function() enabled = false end);

return {
	module_api = {
		disable = function() enabled = false end,
		enable = function() enabled = true end,
		persist = function(key, save, load)
			if not features.hot_reload then
				return;
			end
			assert(type(key) == "string");
			assert(type(save) == "function");
			assert(type(load) == "function");
			assert(not persistence[key]);
			persistence[key] = {
				save = save,
				load = load,
			};
		end
	},
	before_hot_reload = function()
		local savestate = {};
		for key, impl in pairs(persistence) do
			savestate[key] = impl.save();
		end
		return savestate;
	end,
	after_hot_reload = function(savestate)
		for key, data in pairs(savestate) do
			if persistence[key] then
				persistence[key].load(data);
			end
		end
	end,
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
			return enabled;
		end
		return false;
	end
};
