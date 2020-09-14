local CLI = require("engine/dev/cli/CLI");
local CommandStore = require("engine/dev/cli/CommandStore");
local Log = require("engine/dev/Log");
local Assets = require("engine/resources/Assets");
local TableUtils = require("engine/utils/TableUtils");

-- Adapted from lume.hotswap (https://github.com/rxi/lume/)
local reloadModule = function(moduleName)

	local oldGlobal = TableUtils.shallowCopy(_G);
	local updated = {};

	local function update(old, new)
		assert(type(old) == "table");
		assert(type(new) == "table");
		if updated[old] then
			return;
		end
		updated[old] = true;
		local oldmt, newmt = getmetatable(old), getmetatable(new);
		if oldmt and newmt then
			update(oldmt, newmt);
		end
		for k, v in pairs(new) do
			if type(old[k]) == "table" and type(v) == "table" then
				update(old[k], v)
			else
				old[k] = v;
			end
		end
	end

	local function onError(e)
		for k in pairs(_G) do
			_G[k] = oldGlobal[k];
		end
		e = Log:error("Error while hot-reloading " .. tostring(moduleName) .. ": " .. tostring(e) .. "\n");
		error(e);
	end

	_G["hotReloading"] = true;

	local ok, oldmod = pcall(require, moduleName);
	oldmod = ok and oldmod or nil;
	xpcall(function()
		package.loaded[moduleName] = nil;
		local newmod = require(moduleName);
		if type(oldmod) == "table" then
			update(oldmod, newmod);
		end
		for k, v in pairs(oldGlobal) do
			if v ~= _G[k] and type(v) == "table" then
				update(v, _G[k]);
				_G[k] = v;
			end
		end
	end, onError);

	_G["hotReloading"] = false;
end

local hotReload = function()
	local handle = io.popen("git status");
	local gitStatus = handle:read("*a");
	handle:close();

	local filenameRegex = "%s+(%g+)%.([%w%d][%w%d]?[%w%d]?[%w%d]?)";
	for file, ext in string.gmatch(gitStatus, filenameRegex) do
		if ext == "lua" then
			Log:info("Hot-reloading module: " .. file);
			reloadModule(file);
		end
		Assets:refresh(file .. "." .. ext);
	end

	local cli = CLI:new(CommandStore:getGlobalStore());
	cli:execute("save hot_reload");
	cli:execute("load hot_reload");
end

CLI:registerCommand("hotReload", hotReload);
